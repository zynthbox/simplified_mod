/* -*- coding: utf-8 -*-
******************************************************************************
ZYNTHIAN PROJECT: Zynthian Qt GUI

Main Class and Program for Zynthian GUI

Copyright (C) 2021 Marco Martin <mart@kde.org>

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

import QtQuick 2.10
import QtQml 2.15
import QtQuick.Layouts 1.4
import QtQuick.Controls 2.2 as QQC2
import org.kde.kirigami 2.4 as Kirigami
import org.kde.plasma.core 2.0 as PlasmaCore
import "." as Here
import Zynthian 1.0 as Zynthian
import QtGraphicalEffects 1.15

QQC2.Pane {
    id: root
    objectName: "simpleMod"
    property bool debugMode: false
    readonly property string currentEngineId: zynqtgui.curlayerEngineId
    readonly property var selectedChannel : applicationWindow().selectedChannel
    // readonly property string currentSlotPos: root.selectedChannel.id + "/" +root.selectedChannel.selectedSlot.value + "/" +currentEngineId
    // readonly property var curLayer: zynqtgui.curLayer
focus: true


// onVisibleChanged: {
//     if(visible){
//         zynqtgui.current_qml_page = root
//     }
// }
    property var cuiaCallback: function(cuia) {
        _test.text = "cuia"
        switch (cuia) {
            case "SELECT_UP":
            case "SELECT_DOWN":
                if (root.lastSelectedObj === control1) {
                    root.lastSelectedObj = control2
                } else if (root.lastSelectedObj === control2) {
                    root.lastSelectedObj = control1
                } else if (root.lastSelectedObj === control3) {
                    root.lastSelectedObj = control4
                } else if (root.lastSelectedObj === control4) {
                    root.lastSelectedObj = control3
                } else {
                    root.lastSelectedObj = control1
                }

                return true
            case "NAVIGATE_LEFT":
            case "NAVIGATE_RIGHT":
                if (root.lastSelectedObj === control1) {
                    root.lastSelectedObj = control3
                } else if (root.lastSelectedObj === control2) {
                    root.lastSelectedObj = control4
                } else if (root.lastSelectedObj === control3) {
                    root.lastSelectedObj = control1
                } else if (root.lastSelectedObj === control4) {
                    root.lastSelectedObj = control2
                } else {
                    root.lastSelectedObj = control1
                }
                return true
            case "KNOB0_UP":
                _test.text = "1"
                _cutoffDial.increase()
                return true
            case "KNOB0_DOWN":
                _test.text = "2"
                 _cutoffDial.decrease()
                return true
            case "KNOB1_UP":
            case "KNOB1_DOWN":
            case "KNOB2_UP":
            case "KNOB2_DOWN":
                return true
            case "KNOB3_UP":
                _test.text = "3"
                _cutoffDial.increase()
                return true
            case "KNOB3_DOWN":
                _test.text = "4"
                _cutoffDial.decrease()
                return true
            case "SWITCH_SELECT_SHORT":
            case "SWITCH_SELECT_BOLD":
                return true
            default:
                return false;
        }
    }


    Connections{
        target: zynqtgui.control
        onAll_controlsChanged :
        {
            update()
        }
    }

    function update() {
        _loader.active = false
        _loader.active = true
    }

    readonly property var synthMap : {
        'ZBP_SYNTH_00008': {
            'cutoff': ["DCF1_CUTOFF","DCF2_CUTOFF"],
            'resonance': ['DCF1_RESO','DCF2_RESO'],
            'filterAttack' : ['DCF1_ATTACK', 'DCF2_ATTACK'],
            'filterRelease' : ['DCF1_RELEASE', 'DCF2_RELEASE'],
            'filterType' : ['DCF1_TYPE', 'DCF2_TYPE'],
            'ampAttack' : ['DCA1_ATTACK', 'DCA2_ATTACK'],
            'ampRelease' : ['DCA1_RELEASE', 'DCA2_RELEASE']},
        'ZBP_SYNTH_00012': {
            'cutoff':  ["cutoff"],
            'resonance': ['resonance'],
            'filterAttack': ['filterattack'],
            'filterRelease': ['filterrelease'],
            'filterType' : ['filterenvamount'],
            'ampAttack': ['attack'],
            'ampRelease': ['release']},
        'ZBP_SYNTH_00009': {
            'cutoff':  ["cutoff"],
            'resonance': ['resonance'],
            'filterAttack': ['fil_attack'],
            'filterRelease': ['fil_release'],
            'filterType' : [],
            'ampAttack': ['amp_attack'],
            'ampRelease': ['amp_release']},
        'ZBP_SYNTH_00011': {
            'cutoff': ["filter cutoff"],
            'resonance': ['filter resonance'],
            'filterAttack': [],
            'filterRelease': [],
            'filterType' : [],
            'ampAttack': [],
            'ampRelease': []},
        'ZBP_SYNTH_00003': {
            'cutoff': ["flt_hp_cutoff_upper", "flt_hp_cutoff_lower"],
            'resonance': [],
            'filterAttack': [],
            'filterRelease': [],
            'filterType' : [],
            'ampAttack': [],
            'ampRelease': []},
        'ZBP_SYNTH_00006': {
            'cutoff': ["DCF1_CUTOFF"],
            'resonance': ['DCF1_RESO'],
            'filterAttack': ['DCF1_ATTACK'],
            'filterRelease': ['DCF1_RELEASE'],
            'filterType' : ['DCF1_TYPE'],
            'ampAttack': ['DCA1_ATTACK'],
            'ampRelease': ['DCA1_RELEASE']},
        'ZBP_SYNTH_00001': {
            'cutoff':  ["cutoff"],
            'resonance': ['resonance'],
            'filterType' : [],
            'filterAttack' : []},
        'ZBP_SYNTH_00004': {
            'cutoff':  ["cutoff"],
            'resonance': ['resonance'],
            'filterAttack' : ['filterattack'],
            'filterRelease': ['filterrelease'],
            'filterType' : ['filtertype'],
            'ampAttack': ['ampattack'],
            'ampRelease': ['amprelease']},
        'ZBP_SYNTH_00002': {
            'cutoff': ["filter_cutoff"],
            'resonance': ['filter_resonance'],
            'filterAttack' : ['filter_attack'],
            'filterRelease': ['filter_release'],
            'filterType' : [],
            'ampAttack': ['attack'],
            'ampRelease': ['release']},
        'ZBP_SYNTH_00013': {
            'cutoff': ["a_filter1_cutoff","a_filter2_cutoff","b_filter1_cutoff","b_filter2_cutoff"],
            'resonance': ['a_filter1_resonance', 'a_filter2_resonance','b_filter1_resonance','b_filter2_resonance'],
            'filterType' : ['a_filter1_type', 'a_filter2_type', 'b_filter1_type', 'b_filter2_type'],
            'filterAttack' : ['a_env1_attack', 'a_env2_attack'],
            'filterRelease' : ['a_env1_release', 'a_env2_release']},
        'ZBP_SYNTH_00000': {
            'cutoff': ["cutoff"],
            'resonance': ['res'],
            'filterAttack' : [],
            'filterRelease' : [],
            'filterType' : ['filter'],
            'ampAttack': ['adsr_a', 'adsr2_a'],
            'ampRelease': ['adsr_r', 'adsr2_r']}
    }

    contentItem: QQC2.Control {
        enabled: root.currentEngineId != null
        padding: 10

        background: Item {
            PlasmaCore.FrameSvgItem {
                id: svgBg4
                anchors.fill: parent

                readonly property real leftPadding: fixedMargins.left
                readonly property real rightPadding: fixedMargins.right
                readonly property real topPadding: fixedMargins.top
                readonly property real bottomPadding: fixedMargins.bottom

                imagePath: "widgets/tracks-background"
                colorGroup: PlasmaCore.Theme.ViewColorGroup
            }
        }

        contentItem: Loader {
            id: _loader
            // asynchronous: true
            sourceComponent: ColumnLayout {
                RowLayout {
                    Layout.fillWidth: true
                    QQC2.Label {
                        text: "Simplified"
                        font.capitalization: Font.AllUppercase
                        font.weight: Font.ExtraBold
                        font.family: "Hack"
                        font.pointSize: 20
                        Layout.alignment: Qt.AlignTop

                        MouseArea {
                            anchors.fill: parent
                            onClicked: root.debugMode = !root.debugMode
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        Text {
                            id: _test
                            text: zynqtgui.current_qml_page.objectName
                        }
                    }

                    QQC2.Label {
                        text: zynqtgui.curlayerEngineName
                        Layout.alignment: Qt.AlignTop
                        // font.capitalization: Font.AllUppercase
                        font.weight: Font.ExtraBold
                        font.family: "Hack"
                        font.pointSize: 20
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 5

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
                                highlighted : _slider.pressed
                                controllersIds: root.currentEngineId != null && root.synthMap[root.currentEngineId] != null && root.synthMap[root.currentEngineId].filterAttack ? root.synthMap[root.currentEngineId].filterAttack : []

                                Here.Slider {
                                    id: _slider
                                    objectName: "FilterAttack"
                                    Layout.fillHeight: true
                                    Layout.alignment: Qt.AlignCenter
                                    orientation: Qt.Vertical
                                    from:_multiFilterAttackController.from
                                    to:_multiFilterAttackController.to
                                    value: _multiFilterAttackController.value
                                    onMoved:_multiFilterAttackController.setValue(value)
                                }
                            }

                            Here.MultiController {
                                id: _multiFilterReleaseController
                                title: "Filter Release"
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                highlighted : _sliderFRel.pressed
                                controllersIds: root.currentEngineId != null && root.synthMap[root.currentEngineId] != null && root.synthMap[root.currentEngineId].filterRelease ? root.synthMap[root.currentEngineId].filterRelease : []
                                debugMode: root.debugMode

                                Here.Slider {
                                    id: _sliderFRel
                                    objectName: "FilterAttack"
                                    Layout.fillHeight: true
                                    Layout.alignment: Qt.AlignCenter
                                    orientation: Qt.Vertical
                                    from: _multiFilterReleaseController.from
                                    to: _multiFilterReleaseController.to
                                    value: _multiFilterReleaseController.value
                                    onMoved: _multiFilterReleaseController.setValue(value)
                                }
                            }
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.margins: 5

                        ColumnLayout {

                            anchors.fill: parent
                            spacing: 5

                            Here.MultiController {
                                id: _multiCutoffController
                                debugMode: root.debugMode
                                title: "Cutoff"
                                Layout.alignment: Qt.AlignCenter
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                controllersIds: root.currentEngineId != null && root.synthMap[root.currentEngineId] != null && root.synthMap[root.currentEngineId].cutoff ? root.synthMap[root.currentEngineId].cutoff : []

                                Here.Dial {
                                    id: _cutoffDial
                                    text: _multiCutoffController.displayText
                                    implicitWidth: height
                                    Layout.fillHeight: true
                                    Layout.alignment: Qt.AlignCenter
                                    // orientation: Qt.Vertical
                                    from: _multiCutoffController.from
                                    to: _multiCutoffController.to
                                    value: _multiCutoffController.value > 0 ?_multiCutoffController.value  : 0
                                    onMoved:_multiCutoffController.setValue(value)

                                    onVisibleChanged: {
                                        _cutoffDial.value = Qt.binding(()=>{return _multiCutoffController.value})
                                    }

                                    Component.onCompleted: {
                                        _cutoffDial.value = Qt.binding(()=>{return _multiCutoffController.value})
                                    }
                                }

                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 150
                                Layout.maximumHeight: 150

                                Here.MultiController {
                                    id: _multiResController
                                    title: "Resonance"
                                    Layout.alignment: Qt.AlignCenter
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    highlighted : _resDial.pressed
                                    controllersIds: root.currentEngineId != null && root.synthMap[root.currentEngineId] != null && root.synthMap[root.currentEngineId].resonance ? root.synthMap[root.currentEngineId].resonance : []
                                    debugMode: root.debugMode

                                    Here.Dial {
                                        id: _resDial
                                        Layout.fillHeight: true
                                        implicitWidth: height
                                        Layout.alignment: Qt.AlignCenter
                                        // orientation: Qt.Vertical
                                        from:_multiResController.from
                                        to:_multiResController.to
                                        value: _multiResController.value
                                        onMoved:_multiResController.setValue(value)
                                    }
                                }

                                Here.FilterTypeController {
                                    id: _multiTypeController
                                    title: "Type"
                                    Layout.alignment: Qt.AlignCenter
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    highlighted : _typeDial.pressed
                                    controllersIds: root.currentEngineId != null && root.synthMap[root.currentEngineId] != null && root.synthMap[root.currentEngineId].filterType ? root.synthMap[root.currentEngineId].filterType : []
                                    debugMode: root.debugMode

                                    Here.Dial {
                                        id: _typeDial
                                        Layout.fillHeight: true
                                        implicitWidth: height
                                        Layout.alignment: Qt.AlignCenter
                                        // orientation: Qt.Vertical
                                        from:_multiTypeController.from
                                        to:_multiTypeController.to
                                        value: _multiTypeController.value
                                        stepSize: _multiTypeController.stepSize
                                        onMoved:_multiTypeController.setValue(value)
                                    }
                                }
                            }
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.margins: 5

                        RowLayout {
                            anchors.fill: parent
                            spacing: 5
                            Here.MultiController {
                                debugMode: root.debugMode
                                id: _multiAmpAttackController
                                title: "Amp Attack"
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                highlighted : _sliderAAtack.pressed
                                controllersIds: root.currentEngineId != null && root.synthMap[root.currentEngineId] != null && root.synthMap[root.currentEngineId].ampAttack ? root.synthMap[root.currentEngineId].ampAttack : []

                                Here.Slider {
                                    id: _sliderAAtack
                                    objectName: "FilterAttack"
                                    Layout.fillHeight: true
                                    Layout.alignment: Qt.AlignCenter
                                    orientation: Qt.Vertical
                                    from:_multiAmpAttackController.from
                                    to:_multiAmpAttackController.to
                                    value: _multiAmpAttackController.value
                                    onMoved:_multiAmpAttackController.setValue(value)
                                }
                            }

                            Here.MultiController {
                                id: _multiAmpReleaseController
                                debugMode: root.debugMode
                                title: "Amp Release"
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                highlighted : _sliderARel.pressed
                                controllersIds: root.currentEngineId != null && root.synthMap[root.currentEngineId] != null && root.synthMap[root.currentEngineId].ampRelease ? root.synthMap[root.currentEngineId].ampRelease : []

                                Here.Slider {
                                    id: _sliderARel
                                    objectName: "FilterAttack"
                                    Layout.fillHeight: true
                                    Layout.alignment: Qt.AlignCenter
                                    orientation: Qt.Vertical
                                    from: _multiAmpReleaseController.from
                                    to: _multiAmpReleaseController.to
                                    value: _multiAmpReleaseController.value
                                    onMoved:_multiAmpReleaseController.setValue(value)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}


