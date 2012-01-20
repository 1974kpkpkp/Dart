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
package com.google.dart.tools.debug.ui.internal.browser;

import com.google.dart.tools.core.generator.DartHtmlGenerator;
import com.google.dart.tools.core.internal.builder.DartBuilder;
import com.google.dart.tools.debug.core.DartDebugCorePlugin;
import com.google.dart.tools.debug.core.DartLaunchConfigWrapper;
import com.google.dart.tools.debug.ui.internal.DartDebugUIPlugin;
import com.google.dart.tools.debug.ui.internal.DartUtil;

import org.eclipse.core.resources.IContainer;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IProgressMonitor;
import org.eclipse.core.runtime.IStatus;
import org.eclipse.core.runtime.NullProgressMonitor;
import org.eclipse.core.runtime.Path;
import org.eclipse.core.runtime.Status;
import org.eclipse.core.runtime.preferences.IEclipsePreferences;
import org.eclipse.debug.core.ILaunch;
import org.eclipse.debug.core.ILaunchConfiguration;
import org.eclipse.debug.core.ILaunchManager;
import org.eclipse.debug.core.model.LaunchConfigurationDelegate;
import org.eclipse.swt.program.Program;

import java.io.File;

/**
 * Launches the Dart application (compiled to js) in the browser
 */
public class BrowserLaunchConfigurationDelegate extends LaunchConfigurationDelegate {

  @Override
  public void launch(ILaunchConfiguration config, String mode, ILaunch launch,
      IProgressMonitor monitor) throws CoreException {
    mode = ILaunchManager.RUN_MODE;

    DartLaunchConfigWrapper launchConfig = new DartLaunchConfigWrapper(config);

    IResource resource = launchConfig.getApplicationResource();

    if (resource instanceof IFile) {
      launchBrowserForHtmlFile((IFile) resource, launchConfig.getApplicationName());
    }
  }

  private Program findProgram(String name) {
    Program[] programs = Program.getPrograms();
    for (Program program : programs) {
      if (program.getName().equals(name)) {
        return program;
      }
    }

    return null;
  }

  /**
   * Based upon the specified file, return the web page to be displayed in the browser. If the
   * specified file is a web page, then return it. Otherwise create a new web page referencing that
   * file.
   * 
   * @param file a web page or a Dart application
   * @return a web page to display the Dart application (not <code>null</code>)
   */
  @SuppressWarnings("unused")
  private IFile getWebPage(IFile file) throws CoreException {
    // If it is already a web page, then just return it
    if (DartUtil.isWebPage(file)) {
      return file;
    }

    // Look for an HTML file with the same name in the folder hierarchy
    String name = file.getName();
    String extension = file.getFileExtension();
    if (extension != null) {
      name = name.substring(0, name.length() - extension.length() - 1);
    }
    name += ".html";
    IContainer container = file.getParent();
    while (container.getType() != IResource.ROOT) {
      IFile htmlFile = container.getFile(new Path(name));
      if (htmlFile.exists()) {
        return htmlFile;
      }
      container = container.getParent();
    }

    // Otherwise, assume it is a Dart app, and return a web page displaying it
    File appJsFile = DartBuilder.getJsAppArtifactFile(file);
    if (!appJsFile.exists()) {
      throwCoreException("Compiled Dart application does not exist: " + appJsFile);
    }
    container = file.getParent();
    IFile htmlFile = container.getFile(new Path(file.getName()).removeFileExtension().append("html"));
    if (htmlFile.exists()) {
      return htmlFile;
    }

    // Exclude the file extension from the title
    String title = file.getName();
    int index = title.lastIndexOf('.');
    if (index > 0) {
      title = title.substring(0, index);
    }

    // If the web page does not exist, then create it
    DartHtmlGenerator generator = new DartHtmlGenerator(true);
    generator.setContainer(container);
    // TODO (danrubel) need to modify generator to take a File rather than IFile
    //generator.setDartAppFile(jsFile);
    generator.setName(appJsFile.getName());
    generator.setTitle(title);
    generator.execute(new NullProgressMonitor());

    return htmlFile;
  }

  private void launchBrowserForHtmlFile(IFile file, String location) {
    // TODO(keertip): change this to use info stored in launch config
    boolean useDefaultBrowser = false;
    IEclipsePreferences prefs = DartDebugCorePlugin.getPlugin().getPrefs();
    useDefaultBrowser = prefs.getBoolean(DartDebugCorePlugin.PREFS_DEFAULT_BROWSER, true);
    if (!useDefaultBrowser) {
      String browserName = prefs.get(DartDebugCorePlugin.PREFS_BROWSER_NAME, "");
      if (!browserName.isEmpty()) {
        Program program = findProgram(browserName);
        if (program != null) {
          program.execute(location);
        }
      }
    }
  }

  /**
   * Throw a core exception with the specified message
   * 
   * @param message the message
   */
  private void throwCoreException(String message) throws CoreException {
    throw new CoreException(new Status(IStatus.ERROR, DartDebugUIPlugin.PLUGIN_ID, message));
  }

}
