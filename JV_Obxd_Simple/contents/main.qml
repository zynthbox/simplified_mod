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
import QtQuick.Layouts 1.4
import QtQuick.Controls 2.2 as QQC2
import org.kde.kirigami 2.4 as Kirigami
import org.kde.plasma.core 2.0 as PlasmaCore
import "." as Here
import Zynthian 1.0 as Zynthian
import QtGraphicalEffects 1.15

Item {
    id: root

    QQC2.Control {

        anchors.fill: parent
        padding: 20

        background: Item {
            PlasmaCore.FrameSvgItem {
                id: svgBg4
                // visible: fromCurrentTheme
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
                // RowLayout {
                //     Layout.fillWidth: true
                //     QQC2.Label {

                //         text: "Filter"
                //         font.capitalization: Font.AllUppercase
                //         font.weight: Font.ExtraBold
                //         font.family: "Hack"
                //         font.pointSize: 20
                //         Layout.alignment: Qt.AlignTop
                //     }

                //     Item {
                //         Layout.fillWidth: true
                //     }

                //     QQC2.Label {
                //         text: "OBXD"
                //         Layout.alignment: Qt.AlignTop
                //         font.capitalization: Font.AllUppercase
                //         font.weight: Font.ExtraBold
                //         font.family: "Hack"
                //         font.pointSize: 20
                //     }
                // }

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

                            Here.SliderControl {
                                objectName: "FilterAttack"
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                slider.orientation: Qt.Vertical

                                controller {
                                    category: "Ctrls#14"
                                    index: 3
                                }
                            }

                            Here.SliderControl {
                                objectName: "FilterRelease"
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                slider.orientation: Qt.Vertical
                                controller {
                                    category: "Ctrls#15"
                                    index: 2
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

                            Here.DialControl {
                                Layout.alignment: Qt.AlignCenter
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                controller {
                                    category: "Ctrls#12"
                                    index: 0
                                }
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 150
                                Layout.maximumHeight: 150

                                Here.DialControl {
                                    objectName: "Resonance"
                                    Layout.fillHeight: true
                                    Layout.fillWidth: true
                                    implicitWidth: height

                                    controller {
                                        category: "Ctrls#12"
                                        index: 1
                                    }
                                }

                                Zynthian.AbstractController {
                                    id: lowpassId
                                    implicitWidth: 200
                                    implicitHeight: 60
                                    Layout.fillWidth: true
                                    Layout.preferredHeight: 60
                                    Layout.maximumHeight: 60
                                    Layout.alignment: Qt.AlignHCenter
                                    title: qsTr("Lowpass")

                                    property int ctrlval: controller.ctrl.value
                                    controller {
                                        category: "Ctrls#13"
                                        index: 2
                                    }

                                    background: null
                                    control:  QQC2.Button {
                                        id: _btn
                                        padding: 10
                                        font.pointSize: 9
                                        font.family: "Hack"
                                        font.weight: Font.Light
                                        font.letterSpacing: 1
                                        text: lowpassId.controller.ctrl.value > 100 ? qsTr("LowPass 24dB") : qsTr("HiPass 12dB")

                                        onClicked: lowpassId.controller.ctrl.value = checked ? lowpassId.controller.ctrl.max_value : lowpassId.controller.ctrl.value0
                                        checked: lowpassId.controller.ctrl && lowpassId.controller.ctrl.value !== lowpassId.controller.ctrl.value0
                                        background: Item {

                                            Rectangle {
                                                id: _recBtn
                                                radius: height/2
                                                anchors.fill: parent
                                                visible: false
                                                color: _btn.checked?  "#5765f2" : "#333"

                                            }
                                            InnerShadow {
                                                anchors.fill: _recBtn
                                                radius: 8.0
                                                samples: 16
                                                horizontalOffset: -3
                                                verticalOffset: 3
                                                color: "#b0000000"
                                                source: _recBtn
                                            }
                                            Rectangle {
                                                anchors.fill: parent
                                                color: "transparent"
                                                border.color: Qt.darker("#16171C", 2)
                                                radius: height/2

                                                Rectangle {
                                                    anchors.fill: parent
                                                    border.color: Qt.lighter("#333", 1.8)
                                                    border.width: 2
                                                    anchors.margins: 1
                                                    opacity: 0.4
                                                    color: "transparent"
                                                    radius: height/2

                                                    RadialGradient {
                                                        visible: _btn.checked
                                                        anchors.fill: parent
                                                        gradient: Gradient {
                                                            GradientStop { position: 0.0; color: "#b5bbe4" }
                                                            GradientStop { position: 0.5; color: "transparent" }
                                                        }
                                                    }
                                                }
                                            }


                                        }
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
                            Here.SliderControl {
                                objectName: "AmpAttack"
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                slider.orientation: Qt.Vertical

                                controller {
                                    category: "Ctrls#13"
                                    index: 3
                                }
                            }

                            Here.SliderControl {
                                objectName: "AmpRelease"
                                Layout.fillHeight: true
                                Layout.fillWidth: true
                                slider.orientation: Qt.Vertical

                                controller {
                                    category: "Ctrls#14"
                                    index: 2
                                }
                            }
                        }


                    }
                }
            }
        }
    }
}

