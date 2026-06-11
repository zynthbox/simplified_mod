/* -*- coding: utf-8 -*-
******************************************************************************
ZYNTHIAN PROJECT: Zynthian Qt GUI

Simplified synth control mod

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
import QtQml 2.15
import QtQuick.Layouts 1.4
import QtQuick.Controls 2.15 as QQC2
import org.kde.kirigami 2.4 as Kirigami
import org.kde.plasma.core 2.0 as PlasmaCore
import "." as Here
import io.zynthbox.ui 1.0 as ZUI

ZUI.ScreenPage {
    id: root
    objectName: "simpleMod"
    property bool debugMode: false

    readonly property string currentEngineId: zynqtgui.curlayerEngineId
    
    // selectedChannel is updated through a throttle (debounced, and held back
    // until the song finishes loading) rather than bound directly, matching
    // TracksBar — this avoids thrashing the control bindings on rapid channel
    // changes and during song load.
    property QtObject selectedChannel: null
    readonly property int selectedSlotRow: root.selectedChannel ? root.selectedChannel.selectedSlotRow : 0

    Timer {
        id: selectedChannelThrottle
        interval: 1; running: false; repeat: false;
        onTriggered: {
            if (zynqtgui.sketchpad.song && zynqtgui.sketchpad.song.isLoading == false) {
                root.selectedChannel = applicationWindow().selectedChannel;
            } else {
                selectedChannelThrottle.restart();
            }
        }
    }
    Connections {
        target: applicationWindow()
        onSelectedChannelChanged: selectedChannelThrottle.restart()
    }
    Component.onCompleted: selectedChannelThrottle.restart()

    // Focus the first enabled control once the channel first becomes available
    // (the throttle populates it after load, by which point the controls are
    // enabled). One-shot so it doesn't steal focus on later track switches.
    property bool _initialFocusDone: false
    onSelectedChannelChanged: {
        if (root.selectedChannel && !root._initialFocusDone) {
            root._initialFocusDone = true
            Qt.callLater(_content.focusFirstEnabled)
        }
    }

    focus: true

    background: Rectangle 
    {
        color: Kirigami.Theme.backgroundColor
        opacity: 0.4
        radius: 10
    }

    property var cuiaCallback: function(cuia) {
        if (_content.cuiaCallback)
            return _content.cuiaCallback(cuia);
        return false;
    }

    contentItem: QQC2.Control {
        enabled: root.currentEngineId != null
        padding: 2

        background: null

        contentItem: Item {
            id: _content
                property int focusIndex: 0
                readonly property var focusOrder: [
                    _multiFilterAttackController,
                    _multiFilterReleaseController,
                    _multiCutoffController,
                    _multiResController,
                    _multiAmpAttackController,
                    _multiAmpReleaseController
                ]

                // Focus the first enabled control (skipping disabled ones). Driven
                // at startup by root.onSelectedChannelChanged, since at Component
                // .onCompleted the throttle hasn't populated the channel yet and
                // the controls are still disabled.
                function focusFirstEnabled() {
                    for (var i = 0; i < focusOrder.length; i++) {
                        if (focusOrder[i].enabled) {
                            focusIndex = i
                            focusOrder[i].forceActiveFocus()
                            return
                        }
                    }
                }

                Component.onCompleted: focusFirstEnabled()

                ColumnLayout {
                    anchors.fill: parent

                    RowLayout {
                        Layout.fillWidth: true

                        // QQC2.Label {
                        //     text: "Simplified"
                        //     font.capitalization: Font.AllUppercase
                        //     font.weight: Font.ExtraBold
                        //     font.family: "Hack"
                        //     font.pointSize: 20
                        //     Layout.alignment: Qt.AlignTop
                        //     MouseArea {
                        //         anchors.fill: parent
                        //         onClicked: root.debugMode = !root.debugMode
                        //     }
                        // }

                        Item { Layout.fillWidth: true }

                        QQC2.Label {
                            text: zynqtgui.curlayerEngineName
                            Layout.alignment: Qt.AlignTop
                            font.weight: Font.ExtraBold
                            font.family: "Hack"
                            font.pointSize: 20
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        spacing: 5

                        // Filter Attack / Release
                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.margins: 5

                            RowLayout {
                                anchors.fill: parent
                                spacing: 5

                                Here.MultiController {
                                    id: _multiFilterAttackController
                                    showFocus: _content.focusIndex === 0
                                    debugMode: root.debugMode
                                    title: "Filter Attack"
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    highlighted: _sliderFAtk.pressed
                                    ctrl: root.selectedChannel ? root.selectedChannel.filterAttackControllers[root.selectedSlotRow] : null
                                    knobControl: _sliderFAtk
                                    onTapped: _content.focusIndex = 0

                                    Here.Slider {
                                        id: _sliderFAtk
                                        Layout.fillHeight: true
                                        Layout.alignment: Qt.AlignCenter
                                        orientation: Qt.Vertical
                                        stepSize: _multiFilterAttackController.stepSize
                                        from: _multiFilterAttackController.from
                                        to: _multiFilterAttackController.to
                                        boundValue: _multiFilterAttackController.value
                                        onMoved: _multiFilterAttackController.setValue(value)
                                    }
                                }

                                Here.MultiController {
                                    id: _multiFilterReleaseController
                                    showFocus: _content.focusIndex === 1
                                    title: "Filter Release"
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    highlighted: _sliderFRel.pressed
                                    ctrl: root.selectedChannel ? root.selectedChannel.filterReleaseControllers[root.selectedSlotRow] : null
                                    debugMode: root.debugMode
                                    knobControl: _sliderFRel
                                    onTapped: _content.focusIndex = 1

                                    Here.Slider {
                                        id: _sliderFRel
                                        Layout.fillHeight: true
                                        Layout.alignment: Qt.AlignCenter
                                        orientation: Qt.Vertical
                                        stepSize: _multiFilterReleaseController.stepSize
                                        from: _multiFilterReleaseController.from
                                        to: _multiFilterReleaseController.to
                                        boundValue: _multiFilterReleaseController.value
                                        onMoved: _multiFilterReleaseController.setValue(value)
                                    }
                                }
                            }
                        }

                        // Cutoff / Resonance / Type
                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.margins: 5

                            ColumnLayout {
                                anchors.fill: parent
                                spacing: 5

                                Here.MultiController {
                                    id: _multiCutoffController
                                    showFocus: _content.focusIndex === 2
                                    ctrl: root.selectedChannel ? root.selectedChannel.filterCutoffControllers[root.selectedSlotRow] : null
                                    title: "Cutoff"
                                    Layout.alignment: Qt.AlignCenter
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    knobControl: _cutoffDial
                                    onTapped: _content.focusIndex = 2

                                    Here.Dial {
                                        id: _cutoffDial
                                        text: _multiCutoffController.displayText
                                        implicitWidth: height
                                        Layout.fillHeight: true
                                        Layout.alignment: Qt.AlignCenter
                                        from: _multiCutoffController.from
                                        to: _multiCutoffController.to
                                        stepSize: _multiCutoffController.stepSize
                                        value: _multiCutoffController.value > 0 ? _multiCutoffController.value : 0
                                        onMoved: _multiCutoffController.setValue(value)
                                        onValueChanged: _multiCutoffController.setValue(value)

                                        onVisibleChanged: {
                                            _cutoffDial.value = Qt.binding(function() { return _multiCutoffController.value })
                                        }
                                        Component.onCompleted: {
                                            _cutoffDial.value = Qt.binding(function() { return _multiCutoffController.value })
                                        }
                                    }
                                }

                                RowLayout {
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 200
                                    Layout.maximumHeight: 200

                                    Here.MultiController {
                                        id: _multiResController
                                        showFocus: _content.focusIndex === 3
                                        title: "Resonance"
                                        Layout.alignment: Qt.AlignCenter
                                        Layout.fillHeight: true
                                        Layout.fillWidth: true
                                        highlighted: _resDial.pressed
                                        ctrl: root.selectedChannel ? root.selectedChannel.filterResonanceControllers[root.selectedSlotRow] : null
                                        debugMode: root.debugMode
                                        knobControl: _resDial
                                        onTapped: _content.focusIndex = 3

                                        Here.Dial {
                                            id: _resDial
                                            text: _multiResController.displayText
                                            Layout.fillHeight: true
                                            implicitWidth: height
                                            Layout.alignment: Qt.AlignCenter
                                            stepSize: _multiResController.stepSize
                                            from: _multiResController.from
                                            to: _multiResController.to
                                            value: _multiResController.value
                                            onMoved: _multiResController.setValue(value)

                                            onVisibleChanged: {
                                                _resDial.value = Qt.binding(function() { return _multiResController.value })
                                            }
                                            Component.onCompleted: {
                                                _resDial.value = Qt.binding(function() { return _multiResController.value })
                                            }
                                        }
                                    }

                                    Here.FilterTypeController {
                                        id: _multiTypeController
                                        title: "Type"
                                        visible: false // TODO: enable when we have a way to set filter type for different engines
                                        enabled: false // TODO: enable when we have a way to set filter type for different engines
                                        Layout.alignment: Qt.AlignCenter
                                        Layout.fillHeight: true
                                        Layout.fillWidth: true
                                        highlighted: _typeDial.pressed
                                        // controllersIds: root.controllersForParam('filterType')
                                        debugMode: root.debugMode
                                        knobControl: _typeDial

                                        Here.Dial {
                                            id: _typeDial
                                            Layout.fillHeight: true
                                            implicitWidth: height
                                            Layout.alignment: Qt.AlignCenter
                                            from: _multiTypeController.from
                                            to: _multiTypeController.to
                                            value: _multiTypeController.value
                                            stepSize: _multiTypeController.stepSize
                                            onMoved: _multiTypeController.setValue(value)
                                        }
                                    }
                                }
                            }
                        }

                        // Amp Attack / Release
                        Item {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.margins: 5

                            RowLayout {
                                anchors.fill: parent
                                spacing: 5

                                Here.MultiController {
                                    id: _multiAmpAttackController
                                    showFocus: _content.focusIndex === 4
                                    debugMode: root.debugMode
                                    title: "Amp Attack"
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    highlighted: _sliderAAtk.pressed
                                    ctrl: root.selectedChannel ? root.selectedChannel.ampAttackControllers[root.selectedSlotRow] : null
                                    knobControl: _sliderAAtk
                                    onTapped: _content.focusIndex = 4

                                    Here.Slider {
                                        id: _sliderAAtk
                                        Layout.fillHeight: true
                                        Layout.alignment: Qt.AlignCenter
                                        orientation: Qt.Vertical
                                        stepSize: _multiAmpAttackController.stepSize
                                        from: _multiAmpAttackController.from
                                        to: _multiAmpAttackController.to
                                        boundValue: _multiAmpAttackController.value
                                        onMoved: _multiAmpAttackController.setValue(value)
                                    }
                                }

                                Here.MultiController {
                                    id: _multiAmpReleaseController
                                    showFocus: _content.focusIndex === 5
                                    debugMode: root.debugMode
                                    title: "Amp Release"
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    highlighted: _sliderARel.pressed
                                    ctrl: root.selectedChannel ? root.selectedChannel.ampReleaseControllers[root.selectedSlotRow] : null
                                    knobControl: _sliderARel 
                                    onTapped: _content.focusIndex = 5

                                    Here.Slider { 
                                        id: _sliderARel
                                        Layout.fillHeight: true
                                        Layout.alignment: Qt.AlignCenter
                                        orientation: Qt.Vertical
                                        stepSize: _multiAmpReleaseController.stepSize
                                        from: _multiAmpReleaseController.from
                                        to: _multiAmpReleaseController.to
                                        boundValue: _multiAmpReleaseController.value
                                        onMoved: _multiAmpReleaseController.setValue(value)
                                    }
                                }
                            }
                        }
                    }
                }

                // Move focus by `step` (+1 forward / -1 back), skipping disabled
                // controllers and wrapping around. Stays on the current one if none
                // of the others are enabled.
                function focusStep(step) {
                    var n = focusOrder.length
                    for (var i = 1; i <= n; i++) {
                        var idx = ((focusIndex + step * i) % n + n) % n
                        if (focusOrder[idx].enabled) {
                            focusIndex = idx
                            break
                        }
                    }
                    focusOrder[focusIndex].forceActiveFocus()
                }

                function cuiaCallback(cuia) {
                    switch (cuia) {
                    case "SELECT_UP":
                    case "NAVIGATE_LEFT":
                        focusStep(-1)
                        return true
                    case "SELECT_DOWN":
                    case "NAVIGATE_RIGHT":
                        focusStep(1)
                        return true
                    case "KNOB0_UP":
                        focusOrder[focusIndex].increaseValue()
                        return true
                    case "KNOB0_DOWN":
                        focusOrder[focusIndex].decreaseValue()
                        return true
                    case "KNOB1_UP":
                    case "KNOB1_DOWN":
                    case "KNOB2_UP":
                    case "KNOB2_DOWN":
                        return true
                    case "KNOB3_UP":
                        focusStep(1)
                        return true
                    case "KNOB3_DOWN":
                        focusStep(-1)
                        return true
                    case "SWITCH_SELECT_SHORT":
                    case "SWITCH_SELECT_BOLD":
                        return true
                    default:
                        return false
                    }
                }
            }
    }
}
