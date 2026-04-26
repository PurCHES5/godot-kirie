const IPC_MESSAGE_EVENT = "kirie:ipc-message";

type AndroidBridge = {
  postMessage(messageJson: string): void;
};

type IosBridge = {
  postMessage(messageJson: string): void;
};

declare global {
  var KirieAndroidBridge: AndroidBridge | undefined;

  var webkit:
    | {
        messageHandlers?: {
          kirie?: IosBridge;
        };
      }
    | undefined;
}

export type KirieIpcMessageHandler<TMessage = unknown> = (message: TMessage) => void;

export function sendIpcMessage(message: unknown): void {
  const messageJson = JSON.stringify(message);
  if (messageJson === undefined) {
    throw new TypeError(
      "Kirie IPC message root must serialize to a JSON string. See https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/JSON/stringify#description for details.",
    );
  }

  const androidBridge = globalThis.KirieAndroidBridge;
  if (androidBridge) {
    androidBridge.postMessage(messageJson);
    return;
  }

  const iosBridge = globalThis.webkit?.messageHandlers?.kirie;
  if (iosBridge) {
    iosBridge.postMessage(messageJson);
    return;
  }

  throw new Error("Kirie native IPC bridge is not available.");
}

export function onIpcMessageReceived<TMessage = unknown>(
  handler: KirieIpcMessageHandler<TMessage>,
): () => void {
  const listener = (event: Event) => {
    handler((event as CustomEvent<TMessage>).detail);
  };

  globalThis.addEventListener(IPC_MESSAGE_EVENT, listener);

  return () => {
    globalThis.removeEventListener(IPC_MESSAGE_EVENT, listener);
  };
}
