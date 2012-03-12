/*
 * Copyright (c) 2012, the Dart project authors.
 * 
 * Licensed under the Eclipse Public License v1.0 (the "License"); you may not use this file except
 * in compliance with the License. You may obtain a copy of the License at
 * 
 * http://www.eclipse.org/legal/epl-v10.html
 * 
 * Unless required by applicable law or agreed to in writing, software distributed under the License
 * is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
 * or implied. See the License for the specific language governing permissions and limitations under
 * the License.
 */

package com.google.dart.tools.ui.internal.filesview;

import com.google.dart.tools.ui.DartToolsPlugin;
import com.google.dart.tools.ui.ProblemsLabelDecorator;
import com.google.dart.tools.ui.actions.CopyFilePathAction;
import com.google.dart.tools.ui.actions.DeleteAction;
import com.google.dart.tools.ui.actions.OpenNewFileWizardAction;
import com.google.dart.tools.ui.actions.OpenNewFolderWizardAction;
import com.google.dart.tools.ui.internal.actions.CollapseAllAction;
import com.google.dart.tools.ui.internal.handlers.OpenFolderHandler;
import com.google.dart.tools.ui.internal.preferences.DartBasePreferencePage;
import com.google.dart.tools.ui.internal.projects.HideProjectAction;
import com.google.dart.tools.ui.internal.util.SWTUtil;

import org.eclipse.core.filesystem.IFileStore;
import org.eclipse.core.resources.IContainer;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IProject;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.resources.ResourcesPlugin;
import org.eclipse.jface.action.IMenuListener;
import org.eclipse.jface.action.IMenuManager;
import org.eclipse.jface.action.IToolBarManager;
import org.eclipse.jface.action.MenuManager;
import org.eclipse.jface.action.Separator;
import org.eclipse.jface.resource.JFaceResources;
import org.eclipse.jface.util.IPropertyChangeListener;
import org.eclipse.jface.util.PropertyChangeEvent;
import org.eclipse.jface.viewers.DecoratingLabelProvider;
import org.eclipse.jface.viewers.DoubleClickEvent;
import org.eclipse.jface.viewers.IDoubleClickListener;
import org.eclipse.jface.viewers.ISelection;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.jface.viewers.StructuredSelection;
import org.eclipse.jface.viewers.TreeViewer;
import org.eclipse.swt.graphics.Font;
import org.eclipse.swt.widgets.Composite;
import org.eclipse.swt.widgets.Menu;
import org.eclipse.swt.widgets.Shell;
import org.eclipse.ui.IMemento;
import org.eclipse.ui.ISharedImages;
import org.eclipse.ui.IViewSite;
import org.eclipse.ui.PartInitException;
import org.eclipse.ui.PlatformUI;
import org.eclipse.ui.actions.MoveResourceAction;
import org.eclipse.ui.actions.RenameResourceAction;
import org.eclipse.ui.ide.IDE;
import org.eclipse.ui.model.WorkbenchLabelProvider;
import org.eclipse.ui.part.ISetSelectionTarget;
import org.eclipse.ui.part.ViewPart;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

/**
 * File-oriented view for navigating Dart projects.
 * <p>
 * This view will replace the current "Libraries" view once a few tasks are completed:
 * <p>
 * TODO Remove the deprecated CreateFileAction and CreateFolderActions with new Dart Editor specific
 * versions
 * <p>
 * TODO modify the builder to ensure that the correct libraries are built when the user makes
 * changes to Dart code
 * <p>
 * TODO re-visit the DeltaProcessor and ensure that all user actions result in a correct update of
 * the model in the viewer
 */
@SuppressWarnings("deprecation")
public class FilesView extends ViewPart implements ISetSelectionTarget {

  private class FontPropertyChangeListener implements IPropertyChangeListener {
    @Override
    public void propertyChange(PropertyChangeEvent event) {
      if (treeViewer != null) {
        if (DartBasePreferencePage.BASE_FONT_KEY.equals(event.getProperty())) {
          updateTreeFont();
        }
      }
    }
  }

  private static boolean allElementsAreProjects(IStructuredSelection selection) {
    for (Iterator<?> iterator = selection.iterator(); iterator.hasNext();) {
      Object selectedElement = iterator.next();
      if (!(selectedElement instanceof IProject)) {
        return false;
      }
    }
    return true;
  }

  private static boolean allElementsAreResources(IStructuredSelection selection) {
    for (Iterator<?> iterator = selection.iterator(); iterator.hasNext();) {
      Object selectedElement = iterator.next();
      if (!(selectedElement instanceof IResource)) {
        return false;
      }
    }
    return true;
  }

  private TreeViewer treeViewer;

  private IMemento memento;
  /**
   * A final static String for the Link with Editor momento.
   */
  private static final String LINK_WITH_EDITOR_ID = "linkWithEditor";
  private LinkWithEditorAction linkWithEditorAction;
  private MoveResourceAction moveAction;
  private RenameResourceAction renameAction;
  private DeleteAction deleteAction;
  private OpenNewFileWizardAction createFileAction;
  private OpenNewFolderWizardAction createFolderAction;

  private CopyFilePathAction copyFilePathAction;

  private HideProjectAction hideContainerAction;

  private IPropertyChangeListener fontPropertyChangeListener = new FontPropertyChangeListener();

  //persistence tags
  private static final String TAG_ELEMENT = "element"; //$NON-NLS-1$
  private static final String TAG_EXPANDED = "expanded"; //$NON-NLS-1$
  private static final String TAG_PATH = "path"; //$NON-NLS-1$
  private static final String TAG_SELECTION = "selection"; //$NON-NLS-1$

  public FilesView() {
  }

  @Override
  public void createPartControl(Composite parent) {
    treeViewer = new TreeViewer(parent);
    treeViewer.setContentProvider(new ResourceContentProvider());
    //TODO (pquitslund): replace with WorkbenchLabelProvider.getDecoratingWorkbenchLabelProvider() 
    // when we have the linked resource story straightened out
//    treeViewer.setLabelProvider(WorkbenchLabelProvider.getDecoratingWorkbenchLabelProvider());
    treeViewer.setLabelProvider(new DecoratingLabelProvider(new WorkbenchLabelProvider(),
        new ProblemsLabelDecorator()));
    treeViewer.setComparator(new FilesViewerComparator());
    treeViewer.addDoubleClickListener(new IDoubleClickListener() {
      @Override
      public void doubleClick(DoubleClickEvent event) {
        handleDoubleClick(event);
      }
    });
    treeViewer.setInput(ResourcesPlugin.getWorkspace().getRoot());

    getSite().setSelectionProvider(treeViewer);

    fillInToolbar(getViewSite().getActionBars().getToolBarManager());

    // Create the TreeViewer's context menu.
    createContextMenu();

    parent.getDisplay().asyncExec(new Runnable() {
      @Override
      public void run() {
        linkWithEditorAction.syncSelectionToEditor();
      }
    });

    createFileAction = new OpenNewFileWizardAction(getSite().getWorkbenchWindow());
    treeViewer.addSelectionChangedListener(createFileAction);
    createFolderAction = new OpenNewFolderWizardAction(getSite().getWorkbenchWindow());
    treeViewer.addSelectionChangedListener(createFolderAction);
    renameAction = new RenameResourceAction(getShell(), treeViewer.getTree());
    treeViewer.addSelectionChangedListener(renameAction);
    moveAction = new MoveResourceAction(getShell());
    treeViewer.addSelectionChangedListener(moveAction);

    deleteAction = new DeleteAction(getSite());
    deleteAction.setImageDescriptor(PlatformUI.getWorkbench().getSharedImages().getImageDescriptor(
        ISharedImages.IMG_TOOL_DELETE));
    treeViewer.addSelectionChangedListener(deleteAction);

    hideContainerAction = new HideProjectAction(getSite());
    treeViewer.addSelectionChangedListener(hideContainerAction);

    copyFilePathAction = new CopyFilePathAction(getSite());
    treeViewer.addSelectionChangedListener(copyFilePathAction);

    JFaceResources.getFontRegistry().addListener(fontPropertyChangeListener);
    updateTreeFont();

    restoreState();
  }

  @Override
  public void dispose() {
    if (linkWithEditorAction != null) {
      linkWithEditorAction.dispose();
    }

    treeViewer.removeSelectionChangedListener(copyFilePathAction);

    super.dispose();
  }

  @Override
  public void init(IViewSite site, IMemento memento) throws PartInitException {
    super.init(site, memento);

    this.memento = memento;
  }

  @Override
  public void saveState(IMemento memento) {
    memento.putBoolean(LINK_WITH_EDITOR_ID, linkWithEditorAction.getLinkWithEditor());

    //save expanded elements
    Object expandedElements[] = treeViewer.getVisibleExpandedElements();
    if (expandedElements.length > 0) {
      IMemento expandedMem = memento.createChild(TAG_EXPANDED);
      for (Object element : expandedElements) {
        if (element instanceof IResource) {
          IMemento elementMem = expandedMem.createChild(TAG_ELEMENT);
          elementMem.putString(TAG_PATH, ((IResource) element).getFullPath().toString());
        }
      }
    }

    //save selection
    Object elements[] = ((IStructuredSelection) treeViewer.getSelection()).toArray();
    if (elements.length > 0) {
      IMemento selectionMem = memento.createChild(TAG_SELECTION);
      for (Object element : elements) {
        if (element instanceof IResource) {
          IMemento elementMem = selectionMem.createChild(TAG_ELEMENT);
          elementMem.putString(TAG_PATH, ((IResource) element).getFullPath().toString());
        }
      }
    }

  }

  @Override
  public void selectReveal(ISelection selection) {
    treeViewer.setSelection(selection, true);
  }

  @Override
  public void setFocus() {
    treeViewer.getTree().setFocus();
  }

  protected void createContextMenu() {
    MenuManager menuMgr = new MenuManager("#PopupMenu"); //$NON-NLS-1$
    menuMgr.setRemoveAllWhenShown(true);
    menuMgr.addMenuListener(new IMenuListener() {
      @Override
      public void menuAboutToShow(IMenuManager manager) {
        fillContextMenu(manager);
      }
    });
    Menu menu = menuMgr.createContextMenu(treeViewer.getTree());
    treeViewer.getTree().setMenu(menu);
    getSite().registerContextMenu(menuMgr, treeViewer);
  }

  protected void fillContextMenu(IMenuManager manager) {

    // New File/ New Folder 

    manager.add(createFileAction);
    manager.add(createFolderAction);

    // OPEN GROUP

    manager.add(new Separator());
    manager.add(OpenFolderHandler.createCommandAction(getSite().getWorkbenchWindow()));

    IStructuredSelection selection = (IStructuredSelection) treeViewer.getSelection();

    // REFACTOR GROUP

    // Refactor iff all elements are IResources

    if (!selection.isEmpty() && allElementsAreResources(selection)) {
      manager.add(new Separator());
      if (selection.size() == 1) {
        manager.add(renameAction);
        manager.add(moveAction);
      }
      manager.add(deleteAction);
    }

    // Remove, iff non-empty selection, all elements are IResources

    if (!selection.isEmpty() && allElementsAreResources(selection)) {

      // Copy File Path iff single element and is an IResource

      if (selection.size() == 1) {
        manager.add(new Separator());
        manager.add(copyFilePathAction);
      }

      manager.add(new Separator());
      if (allElementsAreProjects(selection)) {
        manager.add(hideContainerAction);
      }
    }

  }

  protected void fillInToolbar(IToolBarManager toolbar) {

    // Link with Editor

    linkWithEditorAction = new LinkWithEditorAction(getViewSite().getPage(), treeViewer);

    if (memento != null && memento.getBoolean(LINK_WITH_EDITOR_ID) != null) {
      linkWithEditorAction.setLinkWithEditor(memento.getBoolean(LINK_WITH_EDITOR_ID).booleanValue());
    } else {
      linkWithEditorAction.setLinkWithEditor(true);
    }

    // Collapse All

    toolbar.add(new CollapseAllAction(treeViewer));
    toolbar.add(linkWithEditorAction);
  }

  protected void handleDoubleClick(DoubleClickEvent event) {
    IStructuredSelection selection = (IStructuredSelection) event.getSelection();
    Object element = selection.getFirstElement();

    if (treeViewer.isExpandable(element)) {
      treeViewer.setExpandedState(element, !treeViewer.getExpandedState(element));
    }

    if (element instanceof IFile) {
      try {
        IDE.openEditor(getViewSite().getPage(), (IFile) element);
      } catch (PartInitException e) {
        DartToolsPlugin.log(e);
      }
    } else if (element instanceof IFileStore) {
      try {
        IDE.openEditorOnFileStore(getViewSite().getPage(), (IFileStore) element);
      } catch (PartInitException e) {
        DartToolsPlugin.log(e);
      }
    }
  }

  protected void restoreState() {
    if (memento == null) {
      return;
    }

    IContainer container = ResourcesPlugin.getWorkspace().getRoot();
    //restore expansion
    IMemento childMem = memento.getChild(TAG_EXPANDED);
    if (childMem != null) {
      List<Object> elements = new ArrayList<Object>();
      for (IMemento mem : childMem.getChildren(TAG_ELEMENT)) {
        Object element = container.findMember(mem.getString(TAG_PATH));
        if (element != null) {
          elements.add(element);
        }
      }
      treeViewer.setExpandedElements(elements.toArray());
    }
    //restore selection
    childMem = memento.getChild(TAG_SELECTION);
    if (childMem != null) {
      ArrayList<Object> list = new ArrayList<Object>();
      for (IMemento mem : childMem.getChildren(TAG_ELEMENT)) {
        Object element = container.findMember(mem.getString(TAG_PATH));
        if (element != null) {
          list.add(element);
        }
      }
      treeViewer.setSelection(new StructuredSelection(list));
    }
  }

  protected void updateTreeFont() {
    Font newFont = JFaceResources.getFont(DartBasePreferencePage.BASE_FONT_KEY);
    Font oldFont = treeViewer.getTree().getFont();
    Font font = SWTUtil.changeFontSize(oldFont, newFont);
    treeViewer.getTree().setFont(font);
  }

  private Shell getShell() {
    return getSite().getShell();
  }

}
