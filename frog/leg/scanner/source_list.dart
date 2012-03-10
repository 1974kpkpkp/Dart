// Copyright (c) 2012, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

final List<String> argv = const <String>[
'../client/dom/common/implementation.dart',
'../client/dom/common/public.dart',
'../client/dom/dom.dart',
'../client/dom/scripts/idlparser.dart',
'../client/dom/scripts/idlparser_test.dart',
'../client/dom/scripts/idlrenderer.dart',
'../client/dom/src/DOMType.dart',
'../client/dom/src/EventListener.dart',
'../client/dom/src/KeyLocation.dart',
'../client/dom/src/KeyName.dart',
'../client/dom/src/ReadyState.dart',
'../client/dom/src/TimeoutHandler.dart',
'../client/dom/src/_Collections.dart',
'../client/dom/src/_ListIterators.dart',
'../client/dom/src/_Lists.dart',
'../client/dom/src/dummy_FactoryProviders.dart',
'../client/dom/src/dummy_GlobalProperties.dart',
'../client/dom/src/frog_DOMType.dart',
'../client/dom/src/native_DOMPublic.dart',
'../client/dom/src/native_DOMWrapperBase.dart',
'../client/dom/src/native_FactoryProviders.dart',
'../client/dom/src/native_GlobalProperties.dart',
'../client/html/benchmarks/common/BenchUtil.dart',
'../client/html/benchmarks/common/Interval.dart',
'../client/html/benchmarks/common/JSON.dart',
'../client/html/benchmarks/common/Math2.dart',
'../client/html/benchmarks/dromaeo/Dromaeo.dart',
'../client/html/benchmarks/dromaeo/Suites.dart',
'../client/html/frog/html_frog.dart',
'../client/html/dartium/html_dartium.dart',
'../client/testing/dartest/css.dart',
'../client/testing/dartest/dartest.dart',
'../client/testing/unittest/shared.dart',
'../client/testing/unittest/unittest_dom.dart',
'../client/testing/unittest/unittest_dartest.dart',
'../client/testing/unittest/unittest_node.dart',
'../client/testing/unittest/unittest_vm.dart',
'../corelib/src/bool.dart',
'../corelib/src/collection.dart',
'../corelib/src/comparable.dart',
'../corelib/src/date.dart',
'../corelib/src/double.dart',
'../corelib/src/duration.dart',
'../corelib/src/exceptions.dart',
'../corelib/src/expect.dart',
'../corelib/src/function.dart',
'../corelib/src/future.dart',
'../corelib/src/hashable.dart',
'../corelib/src/implementation/dual_pivot_quicksort.dart',
'../corelib/src/implementation/duration_implementation.dart',
'../corelib/src/implementation/exceptions.dart',
'../corelib/src/implementation/future_implementation.dart',
'../corelib/src/implementation/hash_map_set.dart',
'../corelib/src/implementation/linked_hash_map.dart',
'../corelib/src/implementation/maps.dart',
'../corelib/src/implementation/queue.dart',
'../corelib/src/implementation/splay_tree.dart',
'../corelib/src/implementation/stopwatch_implementation.dart',
'../corelib/src/int.dart',
'../corelib/src/iterable.dart',
'../corelib/src/iterator.dart',
'../corelib/src/list.dart',
'../corelib/src/map.dart',
'../corelib/src/math.dart',
'../corelib/src/num.dart',
'../corelib/src/options.dart',
'../corelib/src/pattern.dart',
'../corelib/src/queue.dart',
'../corelib/src/regexp.dart',
'../corelib/src/set.dart',
'../corelib/src/stopwatch.dart',
'../corelib/src/string.dart',
'../corelib/src/string_buffer.dart',
'../corelib/src/strings.dart',
'../corelib/src/time_zone.dart',
'../lib/json/json.dart',
'../lib/utf/utf.dart',
'../lib/utf/utf_core.dart',
'../lib/utf/utf8.dart',
'../lib/utf/utf16.dart',
'../lib/utf/utf32.dart',
'../lib/uri/uri.dart',
'../lib/isolate/isolate_api.dart',
'../lib/isolate/isolate_frog.dart',
'../lib/isolate/frog/isolateimpl.dart',
'../lib/isolate/frog/ports.dart',
'../lib/isolate/frog/messages.dart',
'../samples/actors/core/actors-dom.dart',
'../samples/actors/core/actors-interface.dart',
'../samples/actors/core/actors-term.dart',
'../samples/actors/core/actors-ui.dart',
'../samples/actors/core/actors-web.dart',
'../samples/actors/core/actors.dart',
'../samples/actors/samples/dartcombat/dartcombat.dart',
'../samples/actors/samples/dartcombat/dartcombatlib.dart',
'../samples/actors/samples/dartcombat/grids.dart',
'../samples/actors/samples/dartcombat/player.dart',
'../samples/actors/samples/dartcombat/setup.dart',
'../samples/actors/samples/dartcombat/state.dart',
'../samples/actors/samples/dartcombat/views.dart',
'../samples/actors/samples/helloworld/helloconcert.dart',
'../samples/actors/samples/helloworld/helloworld.dart',
'../samples/actors/samples/life/life.dart',
'../samples/actors/samples/math/controlflow-recursive.dart',
'../samples/actors/samples/math/sumup.dart',
'../samples/actors/samples/pingpong/pingpong.dart',
'../samples/actors/samples/sssp/graph.dart',
'../samples/actors/samples/sssp/sssp-single.dart',
'../samples/actors/samples/sssp/sssp-util.dart',
'../samples/actors/samples/sssp/sssp.dart',
'../samples/actors/samples/threadring/threadring.dart',
'../samples/belay/bcap/bcap.dart',
'../samples/belay/bcap/bcap_fling.dart',
'../samples/belay/bcap/src/BcapFlingServer.dart',
'../samples/belay/bcap/src/BcapTunnel.dart',
'../samples/belay/bcap/src/BcapUtil.dart',
'../samples/belay/bcap/src/BelayClient.dart',
'../samples/belay/bcap/src/impl_bcap.dart',
'../samples/belay/buzzer/BuzzerServer.dart',
'../samples/belay/buzzer/static/Buzzer.dart',
'../samples/belay/buzzer/static/Index.dart',
'../samples/chat/chat_server.dart',
'../samples/chat/chat_server_lib.dart',
'../samples/chat/chat_stress_client.dart',
'../samples/chat/dart_client/chat.dart',
'../samples/chat/http.dart',
'../samples/chat/http_impl.dart',
'../samples/clock/Ball.dart',
'../samples/clock/Balls.dart',
'../samples/clock/Clock.dart',
'../samples/clock/ClockNumber.dart',
'../samples/clock/ClockNumbers.dart',
'../samples/clock/Colon.dart',
'../samples/clock/Util.dart',
'../samples/dartcombat/dartcombat.dart',
'../samples/dartcombat/dartcombatlib.dart',
'../samples/dartcombat/grids.dart',
'../samples/dartcombat/player.dart',
'../samples/dartcombat/setup.dart',
'../samples/dartcombat/state.dart',
'../samples/dartcombat/views.dart',
'../samples/hi/hi.dart',
'../samples/isolate/HelloIsolate.dart',
'../samples/isolate_html/IsolateSample.dart',
'../samples/isolate_html/isolate_sample.dart',
'../samples/logo/logo.dart',
'../samples/markdown/ast.dart',
'../samples/markdown/block_parser.dart',
'../samples/markdown/html_renderer.dart',
'../samples/markdown/inline_parser.dart',
'../samples/markdown/lib.dart',
'../samples/markdown/markdown.dart',
'../samples/markdown/test/markdown_tests.dart',
'../samples/matrix/float32.dart',
'../samples/matrix/matrix4.dart',
'../samples/matrix/matrix_client.dart',
'../samples/matrix/matrix_server.dart',
'../samples/pond/editors.dart',
'../samples/pond/editors_stub.dart',
'../samples/pond/html_file_system.dart',
'../samples/pond/pond.dart',
'../samples/pond/util.dart',
'../samples/slider/SliderSample.dart',
'../samples/slider/slider_sample.dart',
'../samples/socket/SocketExample.dart',
'../samples/spirodraw/ColorPicker.dart',
'../samples/spirodraw/Spirodraw.dart',
'../samples/sunflower/Sunflower.dart',
'../samples/swarm/App.dart',
'../samples/swarm/BiIterator.dart',
'../samples/swarm/CSS.dart',
'../samples/swarm/CannedData.dart',
'../samples/swarm/ConfigHintDialog.dart',
'../samples/swarm/DataSource.dart',
'../samples/swarm/Decoder.dart',
'../samples/swarm/HelpDialog.dart',
'../samples/swarm/SwarmApp.dart',
'../samples/swarm/SwarmState.dart',
'../samples/swarm/SwarmViews.dart',
'../samples/swarm/UIState.dart',
'../samples/swarm/Views.dart',
'../samples/swarm/swarm.dart',
'../samples/swarm/swarmlib.dart',
'../samples/third_party/dromaeo/Dromaeo.dart',
'../samples/third_party/dromaeo/Suites.dart',
'../samples/third_party/dromaeo/common/BenchUtil.dart',
'../samples/third_party/dromaeo/common/Interval.dart',
'../samples/third_party/dromaeo/common/JSON.dart',
'../samples/third_party/dromaeo/common/Math2.dart',
'../samples/third_party/dromaeo/common/common.dart',
'../samples/time/time_server.dart',
'../samples/total/client/CSVReader.dart',
'../samples/total/client/Cell.dart',
'../samples/total/client/CellContents.dart',
'../samples/total/client/CellLocation.dart',
'../samples/total/client/CellRange.dart',
'../samples/total/client/Chart.dart',
'../samples/total/client/ClientChart.dart',
'../samples/total/client/ColorPicker.dart',
'../samples/total/client/Command.dart',
'../samples/total/client/ContextMenu.dart',
'../samples/total/client/ContextMenuBuilder.dart',
'../samples/total/client/CopyPasteManager.dart',
'../samples/total/client/CssStyles.dart',
'../samples/total/client/DateTimeUtils.dart',
'../samples/total/client/DomUtils.dart',
'../samples/total/client/Exceptions.dart',
'../samples/total/client/Formats.dart',
'../samples/total/client/Formula.dart',
'../samples/total/client/Functions.dart',
'../samples/total/client/GeneralCommand.dart',
'../samples/total/client/HtmlTable.dart',
'../samples/total/client/HtmlUtils.dart',
'../samples/total/client/IdGenerator.dart',
'../samples/total/client/IndexedValue.dart',
'../samples/total/client/InnerMenuView.dart',
'../samples/total/client/Logger.dart',
'../samples/total/client/Parser.dart',
'../samples/total/client/Picker.dart',
'../samples/total/client/PopupHandler.dart',
'../samples/total/client/Reader.dart',
'../samples/total/client/RowCol.dart',
'../samples/total/client/RowColStyle.dart',
'../samples/total/client/SYLKReader.dart',
'../samples/total/client/Scanner.dart',
'../samples/total/client/SelectionManager.dart',
'../samples/total/client/ServerChart.dart',
'../samples/total/client/Spreadsheet.dart',
'../samples/total/client/SpreadsheetLayout.dart',
'../samples/total/client/SpreadsheetListener.dart',
'../samples/total/client/SpreadsheetPresenter.dart',
'../samples/total/client/StringUtils.dart',
'../samples/total/client/Style.dart',
'../samples/total/client/Total.dart',
'../samples/total/client/TotalLib.dart',
'../samples/total/client/UndoStack.dart',
'../samples/total/client/UndoableAction.dart',
'../samples/total/client/Value.dart',
'../samples/total/client/ValuePicker.dart',
'../samples/total/client/ZoomTracker.dart',
'../samples/total/server/DartCompiler.dart',
'../samples/total/server/GetSpreadsheet.dart',
'../samples/total/server/SYLKProducer.dart',
'../samples/total/server/TotalRunner.dart',
'../samples/total/server/TotalServer.dart',
'../samples/ui_lib/base/AnimationScheduler.dart',
'../samples/ui_lib/base/Device.dart',
'../samples/ui_lib/base/DomWrapper.dart',
'../samples/ui_lib/base/Env.dart',
'../samples/ui_lib/base/Size.dart',
'../samples/ui_lib/base/base.dart',
'../samples/ui_lib/layout/GridLayout.dart',
'../samples/ui_lib/layout/GridLayoutParams.dart',
'../samples/ui_lib/layout/GridLayoutParser.dart',
'../samples/ui_lib/layout/GridTracks.dart',
'../samples/ui_lib/layout/SizingFunctions.dart',
'../samples/ui_lib/layout/ViewLayout.dart',
'../samples/ui_lib/layout/layout.dart',
'../samples/ui_lib/observable/ChangeEvent.dart',
'../samples/ui_lib/observable/EventBatch.dart',
'../samples/ui_lib/observable/observable.dart',
'../samples/ui_lib/touch/BezierPhysics.dart',
'../samples/ui_lib/touch/EventUtil.dart',
'../samples/ui_lib/touch/FxUtil.dart',
'../samples/ui_lib/touch/Geometry.dart',
'../samples/ui_lib/touch/InfiniteScroller.dart',
'../samples/ui_lib/touch/Math.dart',
'../samples/ui_lib/touch/ScrollWatcher.dart',
'../samples/ui_lib/touch/Scrollbar.dart',
'../samples/ui_lib/touch/TimeUtil.dart',
'../samples/ui_lib/touch/TouchHandler.dart',
'../samples/ui_lib/touch/touch.dart',
'../samples/ui_lib/util/CollectionUtils.dart',
'../samples/ui_lib/util/DateUtils.dart',
'../samples/ui_lib/util/StringUtils.dart',
'../samples/ui_lib/util/Uri.dart',
'../samples/ui_lib/util/utilslib.dart',
'../samples/ui_lib/view/CompositeView.dart',
'../samples/ui_lib/view/ConveyorView.dart',
'../samples/ui_lib/view/MeasureText.dart',
'../samples/ui_lib/view/PagedViews.dart',
'../samples/ui_lib/view/SliderMenu.dart',
'../samples/ui_lib/view/view.dart',
'./analyze.dart',
'./analyze_frame.dart',
'./block_scope.dart',
'./code_writer.dart',
'./delta_blue.dart',
'./evaluator.dart',
'./file_system.dart',
'./file_system_dom.dart',
'./file_system_memory.dart',
'./file_system_node.dart',
'./file_system_vm.dart',
'./fisk.dart',
'./foo.dart',
'./frog.dart',
'./frog_options.dart',
'./frog_scanner_bench.dart',
'./frogc.dart',
'./js_evaluator_node.dart',
'./lang.dart',
'./leg/compile_time_constants.dart',
'./leg/compiler.dart',
'./leg/diagnostic_listener.dart',
'./leg/elements/elements.dart',
'./leg/emitter.dart',
'./leg/frog_leg.dart',
'./leg/io/io.dart',
'./leg/leg.dart',
'./leg/lib/core.dart',
'./leg/namer.dart',
'./leg/resolver.dart',
'./leg/scanner/array_based_scanner.dart',
'./leg/scanner/byte_array_scanner.dart',
'./leg/scanner/byte_strings.dart',
'./leg/scanner/class_element_parser.dart',
'./leg/scanner/file_with_non_ascii.dart',
'./leg/scanner/listener.dart',
'./leg/scanner/motile.dart',
'./leg/scanner/motile_d8.dart',
'./leg/scanner/motile_node.dart',
'./leg/scanner/node_scanner_bench.dart',
'./leg/scanner/parser.dart',
'./leg/scanner/parser_bench.dart',
'./leg/scanner/parser_task.dart',
'./leg/scanner/partial_parser.dart',
'./leg/scanner/scanner.dart',
'./leg/scanner/scanner_bench.dart',
'./leg/scanner/scanner_implementation.dart',
'./leg/scanner/scanner_task.dart',
'./leg/scanner/scannerlib.dart',
'./leg/scanner/source_list.dart',
'./leg/scanner/string_scanner.dart',
'./leg/scanner/token.dart',
'./leg/scanner/vm_scanner_bench.dart',
'./leg/script.dart',
'./leg/ssa/bailout.dart',
'./leg/ssa/builder.dart',
'./leg/ssa/closure.dart',
'./leg/ssa/codegen_helpers.dart',
'./leg/ssa/nodes.dart',
'./leg/ssa/optimize.dart',
'./leg/ssa/phi_eliminator.dart',
'./leg/ssa/ssa.dart',
'./leg/ssa/tracer.dart',
'./leg/ssa/types.dart',
'./leg/ssa/validate.dart',
'./leg/ssa/value_set.dart',
'./leg/string_validator.dart',
'./leg/tools/mini_parser.dart',
'./leg/tree/nodes.dart',
'./leg/tree/tree.dart',
'./leg/tree/unparser.dart',
'./leg/tree/visitors.dart',
'./leg/tree_validator.dart',
'./leg/typechecker.dart',
'./leg/universe.dart',
'./leg/util/characters.dart',
'./leg/util/link.dart',
'./leg/util/link_implementation.dart',
'./leg/util/util.dart',
'./leg/util/util_implementation.dart',
'./leg/warnings.dart',
'./lib/arrays.dart',
'./lib/collections.dart',
'./lib/num.dart',
'./lib/string_buffer.dart',
'./member_set.dart',
'./method_data.dart',
'./minfrog.dart',
'./minfrogc.dart',
'./reader.dart',
'./samples/ifrog.dart',
'./server/frog_server.dart',
'./server/toss.dart',
'./source.dart',
'./token.dart',
'./tokenizer.dart',
'./tokenizer.g.dart',
'./tree.dart',
'./tree.g.dart',
'./utils.dart'];
