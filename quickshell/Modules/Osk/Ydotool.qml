pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    property int shiftMode: 0 // 0 = off, 1 = shift, 2 = caps lock
    property list<int> shiftKeys: [42, 54]
    property list<int> heldKeys: []

    function press(keycode) {
        Quickshell.execDetached(["ydotool", "key", "--key-delay", "0", `${keycode}:1`]);
    }

    function release(keycode) {
        Quickshell.execDetached(["ydotool", "key", "--key-delay", "0", `${keycode}:0`]);
    }

    function releaseShiftKeys() {
        shiftMode = 0;
        for (let i = 0; i < shiftKeys.length; i++)
            release(shiftKeys[i]);
    }

    function retainHeld(keycode) {
        if (heldKeys.indexOf(keycode) === -1)
            heldKeys = heldKeys.concat([keycode]);
    }

    function releaseHeld(keycode) {
        release(keycode);
        heldKeys = heldKeys.filter(key => key !== keycode);
    }

    function releaseAllKeys() {
        releaseShiftKeys();
        for (let i = 0; i < heldKeys.length; i++)
            release(heldKeys[i]);
        heldKeys = [];
    }
}
