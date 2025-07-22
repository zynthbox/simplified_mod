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

import Zynthian 1.0 as Zynthian


Item {
    id: root

    // Zynthian.ControllerLoader {
    //     anchors.centerIn: parent
    //     height: 200
    //     width: 200
    //     controller {
    //         ctrl: zynqtgui.control.selectedEngineCutoffController
    //     }
    // }

    QQC2.Control {

        anchors.fill: parent
        anchors.margins: svgBg4.inset.top

        padding: svgBg4.visible ? svgBg4.topPadding : Kirigami.Units.smallSpacing
        // bottomPadding: svgBg4.bottomPadding
        // leftPadding: svgBg4.leftPadding
        // rightPadding: svgBg4.rightPadding

        background: Item {
            PlasmaCore.FrameSvgItem {
                id: svgBg4
                visible: fromCurrentTheme
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

            RowLayout {
                anchors.fill: parent

                Zynthian.ControllerLoader {
                    Layout.fillHeight: false
                    Layout.fillWidth: false
                    implicitHeight: 100
                    implicitWidth: 100
                    controller {
                        category: "Ctrls#12"
                        index: 0
                    }
                }

                Zynthian.ControllerLoader {
                    implicitHeight: 200
                    implicitWidth: 200
                    controller {
                        category: "Ctrls#12"
                        index: 0
                    }
                }

                Zynthian.ControllerLoader {
                    Layout.fillHeight: false
                    Layout.fillWidth: false
                    implicitHeight: 100
                    implicitWidth: 100
                    controller {
                        category: "Ctrls#12"
                        index: 0
                    }
                }

            }
        }

    }


    // Zynthian.DialController {
    //         anchors.centerIn: parent
    //         height: 200
    //         width: 200
    //     title: qsTr("Tune")
    //     controller.category: "Ctrls#2"
    //     controller.index: 1
    //     valueLabel: (value > 100 ? "+" : "") + Math.round(value - 100) + "%"
    // }
}

