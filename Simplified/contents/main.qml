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

Item {
    id: root
    property bool debugMode: false

    readonly property var synthMap : {
        'synthv1': {
            'cutoff': ["DCF1_CUTOFF","DCF2_CUTOFF"],
            'resonance': ['DCF1_RESO','DCF2_RESO'],
            'filterAttack' : ['DCF1_ATTACK', 'DCF2_ATTACK'],
            'filterRelease' : ['DCF1_RELEASE', 'DCF2_RELEASE'],
            'filterType' : ['DCF1_TYPE', 'DCF2_TYPE'],
            'ampAttack' : ['DCA1_ATTACK', 'DCA2_ATTACK'],
            'ampRelease' : ['DCA1_RELEASE', 'DCA2_RELEASE']},
        'Obxd': {
            'cutoff':  ["cutoff"],
            'resonance': ['resonance'],
            'filterAttack': ['filterattack'],
            'filterRelease': ['filterrelease'],
            'filterType' : ['filterenvamount'],
            'ampAttack': ['attack'],
            'ampRelease': ['release']},
        'Helm': {
            'cutoff':  ["cutoff"],
            'resonance': ['resonance'],
            'filterAttack': ['fil_attack'],
            'filterRelease': ['fil_release'],
            'filterType' : [],
            'ampAttack': ['amp_attack'],
            'ampRelease': ['amp_release']},
        'ZynAddSubFX': {
            'cutoff': ["filter cutoff"],
            'resonance': ['filter resonance'],
            'filterAttack': [],
            'filterRelease': [],
            'filterType' : [],
            'ampAttack': [],
            'ampRelease': []},
        'String machine': {
            'cutoff': ["flt_hp_cutoff_upper", "flt_hp_cutoff_lower"],
            'resonance': [],
            'filterAttack': [],
            'filterRelease': [],
            'filterType' : [],
            'ampAttack': [],
            'ampRelease': []},
        'padthv1': {
            'cutoff': ["DCF1_CUTOFF"],
            'resonance': ['DCF1_RESO'],
            'filterAttack': ['DCF1_ATTACK'],
            'filterRelease': ['DCF1_RELEASE'],
            'filterType' : ['DCF1_TYPE'],
            'ampAttack': ['DCA1_ATTACK'],
            'ampRelease': ['DCA1_RELEASE']},
        'Nekobi': {
            'cutoff':  ["cutoff"],
            'resonance': ['resonance'],
            'filterType' : [],
            'filterAttack' : []},
        'Noize Mak3r': {
            'cutoff':  ["cutoff"],
            'resonance': ['resonance'],
            'filterAttack' : ['filterattack'],
            'filterRelease': ['filterrelease'],
            'filterType' : ['filtertype'],
            'ampAttack': ['ampattack'],
            'ampRelease': ['amprelease']},
        'Raffo Synth': {
            'cutoff': ["filter_cutoff"],
            'resonance': ['filter_resonance'],
            'filterAttack' : ['filter_attack'],
            'filterRelease': ['filter_release'],
            'filterType' : [],
            'ampAttack': ['attack'],
            'ampRelease': ['release']},
        'Surge': {
            'cutoff': ["a_filter1_cutoff","a_filter2_cutoff","b_filter1_cutoff","b_filter2_cutoff"],
            'resonance': ['a_filter1_resonance', 'a_filter2_resonance','b_filter1_resonance','b_filter2_resonance'],
            'filterType' : ['a_filter1_type', 'a_filter2_type', 'b_filter1_type', 'b_filter2_type'],
            'filterAttack' : ['a_env1_attack', 'a_env2_attack'],
            'filterRelease' : ['a_env1_release', 'a_env2_release']},
        'Calf Monosynth': {
            'cutoff': ["cutoff"],
            'resonance': ['res'],
            'filterAttack' : [],
            'filterRelease' : [],
            'filterType' : ['filter'],
            'ampAttack': ['adsr_a', 'adsr2_a'],
            'ampRelease': ['adsr_r', 'adsr2_r']}
    }

    QQC2.Control {

        anchors.fill: parent
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

        contentItem: Item {
            ColumnLayout {
                anchors.fill: parent
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
                                highlightColor: "#de20ff"
                                title: "Filter Attack"
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                highlighted : _slider.pressed
                                controllersIds: root.synthMap[zynqtgui.curlayerEngineName].filterAttack ? root.synthMap[zynqtgui.curlayerEngineName].filterAttack : []

                                Here.Slider {
                                    id: _slider
                                    objectName: "FilterAttack"
                                    Layout.fillHeight: true
                                    Layout.alignment: Qt.AlignCenter
                                    orientation: Qt.Vertical
                                    highlightColor: _multiFilterAttackController.highlightColor
                                    from:_multiFilterAttackController.from
                                    to:_multiFilterAttackController.to
                                    value: _multiFilterAttackController.value
                                    onMoved:_multiFilterAttackController.setValue(value)
                                }
                            }

                            Here.MultiController {
                                id: _multiFilterReleaseController
                                highlightColor: "#de20ff"
                                title: "Filter Release"
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                highlighted : _sliderFRel.pressed
                                controllersIds: root.synthMap[zynqtgui.curlayerEngineName].filterRelease ? root.synthMap[zynqtgui.curlayerEngineName].filterRelease : []
                                debugMode: root.debugMode

                                Here.Slider {
                                    id: _sliderFRel
                                    objectName: "FilterAttack"
                                    Layout.fillHeight: true
                                    Layout.alignment: Qt.AlignCenter
                                    orientation: Qt.Vertical
                                    highlightColor: _multiFilterReleaseController.highlightColor
                                    from:_multiFilterReleaseController.from
                                    to:_multiFilterReleaseController.to
                                    value: _multiFilterReleaseController.value
                                    onMoved:_multiFilterReleaseController.setValue(value)
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
                                controllersIds: root.synthMap[zynqtgui.curlayerEngineName].cutoff ? root.synthMap[zynqtgui.curlayerEngineName].cutoff : []

                                Here.Dial {
                                    id: _cutoffDial
                                    text: _multiCutoffController.displayText
                                    implicitWidth: height
                                    Layout.fillHeight: true
                                    Layout.alignment: Qt.AlignCenter
                                    // orientation: Qt.Vertical
                                    highlightColor: _multiCutoffController.highlightColor
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
                                    controllersIds: root.synthMap[zynqtgui.curlayerEngineName].resonance ? root.synthMap[zynqtgui.curlayerEngineName].resonance : []
                                    debugMode: root.debugMode

                                    Here.Dial {
                                        id: _resDial
                                        Layout.fillHeight: true
                                        implicitWidth: height
                                        Layout.alignment: Qt.AlignCenter
                                        // orientation: Qt.Vertical
                                        highlightColor: _multiResController.highlightColor
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
                                    controllersIds: root.synthMap[zynqtgui.curlayerEngineName].filterType ? root.synthMap[zynqtgui.curlayerEngineName].filterType : []
                                    debugMode: root.debugMode

                                    Here.Dial {
                                        id: _typeDial
                                        Layout.fillHeight: true
                                        implicitWidth: height
                                        Layout.alignment: Qt.AlignCenter
                                        // orientation: Qt.Vertical
                                        highlightColor: _multiTypeController.highlightColor
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
                                highlightColor: "#de20ff"
                                title: "Amp Attack"
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                highlighted : _sliderAAtack.pressed
                                controllersIds: root.synthMap[zynqtgui.curlayerEngineName].ampAttack ? root.synthMap[zynqtgui.curlayerEngineName].ampAttack : []

                                Here.Slider {
                                    id: _sliderAAtack
                                    objectName: "FilterAttack"
                                    Layout.fillHeight: true
                                    Layout.alignment: Qt.AlignCenter
                                    orientation: Qt.Vertical
                                    highlightColor: _multiAmpAttackController.highlightColor
                                    from:_multiAmpAttackController.from
                                    to:_multiAmpAttackController.to
                                    value: _multiAmpAttackController.value
                                    onMoved:_multiAmpAttackController.setValue(value)
                                }
                            }

                            Here.MultiController {
                                id: _multiAmpReleaseController
                                debugMode: root.debugMode
                                highlightColor: "#de20ff"
                                title: "Amp Release"
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                highlighted : _sliderARel.pressed
                                controllersIds: root.synthMap[zynqtgui.curlayerEngineName].ampRelease  ? root.synthMap[zynqtgui.curlayerEngineName].ampRelease : []


                                Here.Slider {
                                    id: _sliderARel
                                    objectName: "FilterAttack"
                                    Layout.fillHeight: true
                                    Layout.alignment: Qt.AlignCenter
                                    orientation: Qt.Vertical
                                    highlightColor: _multiAmpReleaseController.highlightColor
                                    from:_multiAmpReleaseController.from
                                    to:_multiAmpReleaseController.to
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


