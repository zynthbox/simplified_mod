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
    
    readonly property QtObject selectedChannel: applicationWindow().selectedChannel
    readonly property int selectedSlotRow: root.selectedChannel ? root.selectedChannel.selectedSlotRow : 0

    function ctrlFor(controllers) {
        return root.selectedChannel && controllers ? controllers[root.selectedSlotRow] : null
    }

    focus: true

    background: Rectangle 
    {
        color: Kirigami.Theme.backgroundColor
        opacity: 0.4
        radius: 10
    }

    property var cuiaCallback: function(cuia) {
        if (_loader.item && _loader.item.cuiaCallback)
            return _loader.item.cuiaCallback(cuia);
        return false;
    }

    Connections {
        target: zynqtgui.control
        onAll_controlsChanged: _reloadTimer.restart()
    }

    // Defer the loader reload to the next event-loop tick instead of reacting
    // synchronously. all_controlsChanged is emitted from inside the Python
    // fill_list() call, so recreating the Loader's item tree inline tears down
    // and rebuilds graphical objects reentrantly while `control` is still
    // mutating, which segfaults in the scene graph. The default edit page
    // defers the same signal via a 0ms Timer for the same reason.
    Timer {
        id: _reloadTimer
        interval: 0
        repeat: false
        onTriggered: update()
    }

    function update() {
        _loader.active = false
        _loader.active = true
    }

    contentItem: QQC2.Control {
        enabled: root.currentEngineId != null
        padding: 2

        background: null

        contentItem: Loader {
            id: _loader
            sourceComponent: Item {
                property int focusIndex: 0
                readonly property var focusOrder: [
                    _multiFilterAttackController,
                    _multiFilterReleaseController,
                    _multiCutoffController,
                    _multiResController,
                    _multiAmpAttackController,
                    _multiAmpReleaseController
                ]

                Component.onCompleted: focusOrder[focusIndex].forceActiveFocus()

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
                                    debugMode: root.debugMode
                                    title: "Filter Attack"
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    highlighted: _sliderFAtk.pressed
                                    ctrl: root.ctrlFor(root.selectedChannel ? root.selectedChannel.filterAttackControllers : null)
                                    knobControl: _sliderFAtk
                                    onTapped: {
                                        focusIndex = 0
                                        focusOrder[focusIndex].forceActiveFocus()
                                    }

                                    Here.Slider {
                                        id: _sliderFAtk
                                        Layout.fillHeight: true
                                        Layout.alignment: Qt.AlignCenter
                                        orientation: Qt.Vertical
                                        stepSize: _multiFilterAttackController.stepSize
                                        from: _multiFilterAttackController.from
                                        to: _multiFilterAttackController.to
                                        value: _multiFilterAttackController.value
                                        onMoved: _multiFilterAttackController.setValue(value)
                                    }
                                }

                                Here.MultiController {
                                    id: _multiFilterReleaseController
                                    title: "Filter Release"
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    highlighted: _sliderFRel.pressed
                                    ctrl: root.ctrlFor(root.selectedChannel ? root.selectedChannel.filterReleaseControllers : null)
                                    debugMode: root.debugMode
                                    knobControl: _sliderFRel
                                    onTapped: {
                                        focusIndex = 1
                                        focusOrder[focusIndex].forceActiveFocus()
                                    }

                                    Here.Slider {
                                        id: _sliderFRel
                                        Layout.fillHeight: true
                                        Layout.alignment: Qt.AlignCenter
                                        orientation: Qt.Vertical
                                        stepSize: _multiFilterReleaseController.stepSize
                                        from: _multiFilterReleaseController.from
                                        to: _multiFilterReleaseController.to
                                        value: _multiFilterReleaseController.value
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
                                    ctrl: root.ctrlFor(root.selectedChannel ? root.selectedChannel.filterCutoffControllers : null)
                                    title: "Cutoff"
                                    Layout.alignment: Qt.AlignCenter
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    knobControl: _cutoffDial
                                    onTapped: {
                                        focusIndex = 2
                                        focusOrder[focusIndex].forceActiveFocus()
                                    }

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
                                        title: "Resonance"
                                        Layout.alignment: Qt.AlignCenter
                                        Layout.fillHeight: true
                                        Layout.fillWidth: true
                                        highlighted: _resDial.pressed
                                        ctrl: root.ctrlFor(root.selectedChannel ? root.selectedChannel.filterResonanceControllers : null)
                                        debugMode: root.debugMode
                                        knobControl: _resDial
                                        onTapped: {
                                            focusIndex = 3
                                            focusOrder[focusIndex].forceActiveFocus()
                                        }

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
                                    debugMode: root.debugMode
                                    title: "Amp Attack"
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    highlighted: _sliderAAtk.pressed
                                    ctrl: root.ctrlFor(root.selectedChannel ? root.selectedChannel.ampAttackControllers : null)
                                    knobControl: _sliderAAtk
                                    onTapped: {
                                        focusIndex = 4
                                        focusOrder[focusIndex].forceActiveFocus()
                                    }

                                    Here.Slider {
                                        id: _sliderAAtk
                                        Layout.fillHeight: true
                                        Layout.alignment: Qt.AlignCenter
                                        orientation: Qt.Vertical
                                        stepSize: _multiAmpAttackController.stepSize
                                        from: _multiAmpAttackController.from
                                        to: _multiAmpAttackController.to
                                        value: _multiAmpAttackController.value
                                        onMoved: _multiAmpAttackController.setValue(value)

                                        onVisibleChanged: {
                                            _sliderAAtk.value = Qt.binding(function() { return _multiAmpAttackController.value })
                                        }
                                        Component.onCompleted: {
                                            _sliderAAtk.value = Qt.binding(function() { return _multiAmpAttackController.value })
                                        }
                                    }
                                }

                                Here.MultiController {
                                    id: _multiAmpReleaseController
                                    debugMode: root.debugMode
                                    title: "Amp Release"
                                    Layout.fillWidth: true
                                    Layout.fillHeight: true
                                    highlighted: _sliderARel.pressed
                                    ctrl: root.ctrlFor(root.selectedChannel ? root.selectedChannel.ampReleaseControllers : null)
                                    knobControl: _sliderARel 
                                    onTapped: {
                                        focusIndex = 6
                                        focusOrder[focusIndex].forceActiveFocus()
                                    }

                                    Here.Slider { 
                                        id: _sliderARel
                                        Layout.fillHeight: true
                                        Layout.alignment: Qt.AlignCenter
                                        orientation: Qt.Vertical
                                        stepSize: _multiAmpReleaseController.stepSize
                                        from: _multiAmpReleaseController.from
                                        to: _multiAmpReleaseController.to
                                        value: _multiAmpReleaseController.value
                                        onMoved: _multiAmpReleaseController.setValue(value)
                                    }
                                }
                            }
                        }
                    }
                }

                function cuiaCallback(cuia) {
                    switch (cuia) {
                    case "SELECT_UP":
                    case "NAVIGATE_LEFT":
                        if (focusIndex === 0)
                            focusIndex = focusOrder.length - 1
                        else
                            focusIndex--
                        focusOrder[focusIndex].forceActiveFocus()
                        return true
                    case "SELECT_DOWN":
                    case "NAVIGATE_RIGHT":
                        if (focusIndex === focusOrder.length - 1)
                            focusIndex = 0
                        else
                            focusIndex++
                        focusOrder[focusIndex].forceActiveFocus()
                        return true
                    case "KNOB0_UP":
                        focusOrder[focusIndex].knobControl.increase()
                        return true
                    case "KNOB0_DOWN":
                        focusOrder[focusIndex].knobControl.decrease()
                        return true
                    case "KNOB1_UP":
                    case "KNOB1_DOWN":
                    case "KNOB2_UP":
                    case "KNOB2_DOWN":
                        return true
                    case "KNOB3_UP":
                        if (focusIndex === focusOrder.length - 1)
                            focusIndex = 0
                        else
                            focusIndex++
                        focusOrder[focusIndex].forceActiveFocus()
                        return true
                    case "KNOB3_DOWN":
                        if (focusIndex === 0)
                            focusIndex = focusOrder.length - 1
                        else
                            focusIndex--
                        focusOrder[focusIndex].forceActiveFocus()
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
}
