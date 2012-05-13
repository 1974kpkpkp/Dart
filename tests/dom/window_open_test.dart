#library('WindowOpenTest');
#import('../../lib/unittest/unittest.dart');
#import('../../lib/unittest/dom_config.dart');
#import('dart:dom_deprecated');

main() {
  evaluateJavaScript(code) {
    final scriptTag = document.createElement('script');
    scriptTag.innerHTML = code;
    document.body.appendChild(scriptTag);
  }
  evaluateJavaScript('layoutTestController.setCanOpenWindows()');

  useDomConfiguration();
  asyncTest('TwoArgumentVersion', 1, () {
    Window win = window.open('../resources/pong.html', 'testWindow');
    closeWindow(win);
  });
  asyncTest('ThreeArgumentVersion', 1, () {
    Window win = window.open("resources/pong.html", "testWindow", "scrollbars=yes,width=75,height=100");
    closeWindow(win);
  });
}

closeWindow(win) {
  win.close();
  doneHandler() {
    window.setTimeout(win.closed ? callbackDone : doneHandler, 1);
  }
  window.setTimeout(doneHandler, 1);
}
