/* -*- coding: utf-8 -*-
******************************************************************************
ZYNTHIAN PROJECT: Zynthian Qt GUI

Multi-parameter controller that averages linked synth parameters

Copyright (C) 2026 Camilo Higuita <milo.h@aol.com>

******************************************************************************

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License as
published by the Free Software Foundation; either version 2 of
the License, or any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

For a full copy of the GNU General Public License see the LICENSE.txt file.

******************************************************************************
*/

import QtQuick 2.15
import QtQuick.Layouts 1.4
import QtQuick.Controls 2.15 as QQC2
import QtGraphicalEffects 1.15
import org.kde.kirigami 2.4 as Kirigami

QQC2.Control {
    id: root
    focus: true
    enabled: root.ctrl ? root.ctrl.controlsCount > 0 : false
    opacity: enabled ? 1 : 0.5

    property QtObject ctrl : null
    default property alias content: _container.data

    property double value: ctrl ? ctrl.value : 0.0
    property double from: ctrl ? ctrl.value_min : 0.0
    property double to: ctrl ? ctrl.value_max : 0.0
    property double stepSize: ctrl ? ctrl.step_size : 1.0

    property color highlightColor: "#5765f2"
    property color backgroundColor: "#333"
    property color foregroundColor: "#fafafa"
    property color alternativeColor: "#16171C"

    property bool highlighted: false
    property alias title: _label1.text
    readonly property string displayText: ctrl ? ctrl.value +"%" : "n/a"
    property bool debugMode: false
    property Item knobControl: null
    // Driven by the parent from its focusIndex — Qt's activeFocus is unreliable
    // this deep in the StackLayout, so we track the focused control explicitly.
    property bool showFocus: false

    signal tapped()

    // Pressing the slider/dial child mirrors to the controller via tapped() so it
    // becomes the focused control (same as a background tap). `pressed` is used
    // rather than activeFocus because the latter doesn't reliably propagate here.
    Connections {
        target: root.knobControl
        function onPressedChanged() {
            if (root.knobControl && root.knobControl.pressed)
                root.tapped()
        }
        // The slider's offset touch-target (dummy) doesn't set the real slider's
        // `pressed`, but it forceActiveFocus()es it — catch that case here too.
        function onActiveFocusChanged() {
            if (root.knobControl && root.knobControl.activeFocus)
                root.tapped()
        }
    }

    background: Item {
        TapHandler {
            onTapped: root.tapped()
        }

        Rectangle {
            id: _focusedRect
            anchors.fill: parent
            anchors.margins: -4
            color: "transparent"
            border.color: "white"
            border.width: 2
            visible: root.showFocus && root.enabled
        }
    }

    contentItem: Item {
        ColumnLayout {
            anchors.fill: parent

            QQC2.Label {
                id: _label1
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                font.capitalization: Font.AllUppercase
                font.weight: Font.DemiBold
                font.family: "Hack"
                font.pointSize: 9
                color: root.foregroundColor
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
                ColumnLayout {
                    id: _container
                    anchors.fill: parent
                }
            }

            QQC2.Label {
                visible: enabled
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: root.displayText
                font.capitalization: Font.AllUppercase
                font.weight: Font.DemiBold
                font.family: "Hack"
                font.pointSize: 9
                fontSizeMode: Text.Fit
                minimumPointSize: 6
                wrapMode: Text.NoWrap
                font.letterSpacing: 2
                color: root.foregroundColor
                padding: 4

                MouseArea {
                    anchors.fill: parent
                    onClicked: root.debugMode = !root.debugMode
                }

                background: Rectangle {
                    border.width: 2
                    border.color: root.backgroundColor
                    color: root.alternativeColor
                    radius: 4

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: 1
                        visible: false
                        id: _recLabel
                        color: root.highlighted ? root.highlightColor : root.alternativeColor
                        border.color: Qt.darker(color, 2)
                        radius: 4
                    }

                    InnerShadow {
                        opacity: 0.5
                        anchors.fill: _recLabel
                        radius: 8.0
                        samples: 16
                        horizontalOffset: 3
                        verticalOffset: -1
                        color: "#b0000000"
                        source: _recLabel
                    }

                    InnerShadow {
                        anchors.fill: _recLabel
                        opacity: 0.5
                        radius: 8.0
                        samples: 16
                        horizontalOffset: -3
                        verticalOffset: 1
                        color: "#b0000000"
                        source: _recLabel
                    }
                }
            }
        }
    }

    // Current value as a 0..1 fraction of the control's range (for the knob seek/pick-up system).
    readonly property real seekNormalised: (to > from) ? (value - from) / (to - from) : 0

    function setValue(newValue) {
        if (ctrl) {
            ctrl.value = newValue
        }
    }

    // Fixed-encoder (absolute pot) support: map a 0..1 knob position onto the control's range.
    function setValueAbsolute(newValue) {
        if (ctrl) {
            setValue(Math.round(root.from + newValue * (root.to - root.from)))
        }
    }

    function increaseValue() {
        setValue(root.value + stepSize)
    }

    function decreaseValue() {
        setValue(root.value - stepSize)
    }
}
