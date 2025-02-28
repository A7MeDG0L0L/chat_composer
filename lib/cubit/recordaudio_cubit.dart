import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
part 'recordaudio_state.dart';

Codec codec = Codec.aacADTS;

class RecordAudioCubit extends Cubit<RecordaudioState> {
  final FlutterSoundRecorder _myRecorder = FlutterSoundRecorder();
  final Function()? onRecordStart;
  final Function(String?) onRecordEnd;
  final Function()? onRecordCancel;
  Duration? maxRecordLength;

  ValueNotifier<Duration?> currentDuration = ValueNotifier(Duration.zero);
  late StreamSubscription? recorderStream;

  RecordAudioCubit({
    required this.onRecordEnd,
    required this.onRecordStart,
    required this.onRecordCancel,
    required this.maxRecordLength,
  }) : super(RecordAudioReady()) {
    _myRecorder.openRecorder().then((value) {
      _myRecorder.setSubscriptionDuration(const Duration(milliseconds: 200));
      recorderStream = _myRecorder.onProgress!.listen((event) {
        Duration current = event.duration;
        currentDuration.value = current;
        if (maxRecordLength != null) {
          if (current.inMilliseconds >= maxRecordLength!.inMilliseconds) {
            log('[chat_composer] 🔴 Audio passed max length');
            stopRecord();
          }
        }
      });
    });
  }

  void toggleRecord({required bool canRecord}) {
    emit(canRecord ? RecordAudioReady() : RecordAudioClosed());
  }

  void startRecord() async {
    try {
      _myRecorder.stopRecorder();
    } catch (e) {
      //ignore
    }
    currentDuration.value = Duration.zero;
    try {
      if (!kIsWeb) {
        bool hasStorage = await Permission.storage.isGranted;
        bool hasMic = await Permission.microphone.isGranted;

        if (!hasStorage || !hasMic) {
          if (!hasStorage) await Permission.storage.request();
          if (!hasMic) await Permission.microphone.request();
          log('[chat_composer] 🔴 Denied permissions');
          return;
        }
      }
      if (onRecordStart != null) onRecordStart!();
      if (kIsWeb) codec = Codec.opusWebM;

      Directory? dir = kIsWeb ? null : await getApplicationDocumentsDirectory();
      String path = kIsWeb
          ? 'voiceNote.webm'
          : '${dir?.path}/${DateTime.now().millisecondsSinceEpoch}.aac';

      await _myRecorder.startRecorder(
        toFile: path,
        codec: codec,
      );

      emit(RecordAudioStarted());
    } catch (e, st) {
      debugPrint(e.toString());
      debugPrint(st.toString());
      emit(RecordAudioReady());
    }
  }

  void stopRecord() async {
    // timer.cancel();
    try {
      String? result = await _myRecorder.stopRecorder();
      if (result != null) {
        log('[chat_composer] 🟢 Audio path:  "$result');
        onRecordEnd(result);
      }
    } finally {
      currentDuration.value = Duration.zero;
    }
    emit(RecordAudioReady());
  }

  void cancelRecord() async {
    try {
      _myRecorder.stopRecorder();
    } catch (ignore) {
      //ignore
    }
    emit(RecordAudioReady());
    if (onRecordCancel != null) onRecordCancel!();
    currentDuration.value = Duration.zero;
  }

  @override
  Future<void> close() {
    try {
      _myRecorder.closeRecorder();
    } catch (e) {
      //ignore
    }
    if (recorderStream != null) recorderStream!.cancel();
    try {
      // _myRecorder = null;
      // timer.cancel();
    } catch (e) {
      //ignore
    }
    return super.close();
  }
}
