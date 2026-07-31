/* -*- coding: utf-8 -*-
******************************************************************************
ZYNTHIAN PROJECT: Zynthian Qt GUI

Custom dial control with visual indicators

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

QQC2.Dial {
    id: dial
    focus: false

    implicitWidth: 300
    implicitHeight: 300

    property color highlightColor: "#5765f2"
    property color backgroundColor: "#333"
    property color foregroundColor: "#fafafa"
    property color alternativeColor: "#16171C"

    property alias text: _label1.text

    // Physical KNOB0 position as a 0..1 fraction; -1 hides the marker. Set by the parent only on
    // fixed-encoder (Z2_V5B) hardware + when this control is focused, so you can see where the
    // absolute pot sits relative to the value.
    property real knobPositionNormalised: -1

    inputMode: QQC2.Dial.Circular

    handle: Rectangle {
        id: handleItem
        x: dial.background.x + dial.background.width / 2 - width / 2
        y: dial.background.y + dial.background.height / 2 - height / 2
        width: 8
        height: 8
        radius: width / 2
        color: "white"
        antialiasing: true
        opacity: dial.enabled ? 1 : 0.3

        transform: [
            Translate {
                y: -(_knobInnerIdent.width / 2)
            },
            Rotation {
                angle: dial.angle
                origin.x: handleItem.width / 2
                origin.y: handleItem.height / 2
            }
        ]
    }

    background: Item {

        Item {
            id: _container
            anchors.fill: parent
            anchors.margins: 6

            Repeater {
                id: _indicatorRepeater
                readonly property real startAngle: -140
                readonly property real endAngle: 140
                readonly property real arcSpan: endAngle - startAngle
                readonly property real arcLength: (arcSpan / 360) * Math.PI * _container.width
                readonly property int amount: Math.max(3, Math.round(arcLength / 18))
                model: amount

                Rectangle {
                    id: indicator
                    width: 8
                    height: width
                    radius: width / 2
                    color: highlighted ? dial.highlightColor : dial.alternativeColor
                    border.color: highlighted ? Qt.darker(dial.highlightColor, 1.5) : Qt.darker(dial.alternativeColor, 2)
                    border.width: 1
                    property double threshold: index / (_indicatorRepeater.amount - 1)
                    property bool highlighted: _indicatorRepeater.amount > 1 && dial.position > 0 && dial.position >= threshold
                    property bool active: highlighted
                    opacity: active ? 1 : 0.5

                    onHighlightedChanged: {
                        if (highlighted) {
                            _offTimer.stop()
                            active = true
                        } else {
                            _offTimer.start()
                        }
                    }

                    Timer {
                        id: _offTimer
                        interval: 500
                        onTriggered: indicator.active = false
                    }
                    readonly property real angle: _indicatorRepeater.startAngle + index * (_indicatorRepeater.arcSpan / (_indicatorRepeater.amount - 1))

                    layer.enabled: highlighted
                    layer.effect: Glow {
                        radius: 6
                        samples: 13
                        spread: 0.4
                        color: dial.highlightColor
                    }

                    transform: [
                        Translate {
                            x: _container.width / 2 - width / 2
                        },
                        Rotation {
                            origin.x: _container.width / 2
                            origin.y: _container.height / 2
                            angle: indicator.angle
                        }
                    ]
                }
            }

            // Physical KNOB0 position marker (diamond) on the dial arc.
            Rectangle {
                id: _knobPosMarker
                visible: dial.knobPositionNormalised >= 0
                width: 14; height: 14; radius: 2; rotation: 45
                antialiasing: true
                color: "#ffffff"
                border.color: dial.highlightColor; border.width: 2
                z: 10
                readonly property real ang: (_indicatorRepeater.startAngle
                    + dial.knobPositionNormalised * _indicatorRepeater.arcSpan) * Math.PI / 180
                readonly property real rad: _container.width / 2
                x: _container.width / 2 + rad * Math.sin(ang) - width / 2
                y: _container.height / 2 - rad * Math.cos(ang) - height / 2
            }
        }

        Rectangle {
            id: _innerRect
            anchors.fill: parent
            anchors.margins: _container.anchors.margins + 8 + 8
            color: "transparent"
            radius: width / 2
            border.color: dial.pressed ? dial.highlightColor : Qt.darker(dial.alternativeColor, 2)
            border.width: 2

            LinearGradient {
                anchors.fill: parent
                source: Rectangle {
                    width: _innerRect.width
                    height: _innerRect.height
                    radius: _innerRect.radius
                    visible: false
                }
                start: Qt.point(0, 0)
                end: Qt.point(0, height)
                gradient: Gradient {
                    GradientStop { position: 0.0; color: dial.alternativeColor }
                    GradientStop { position: 1.0; color: Qt.darker(dial.alternativeColor, 1.6) }
                }
            }

            layer.enabled: true
            layer.effect: InnerShadow {
                radius: 10.0
                samples: 20
                horizontalOffset: 0
                verticalOffset: 3
                color: "#c0000000"
            }

            Rectangle {
                id: _knob
                anchors.fill: parent
                anchors.margins: 20
                radius: width / 2
                color: dial.backgroundColor

                ConicalGradient {
                    anchors.fill: parent
                    angle: dial.angle + 90
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: dial.backgroundColor }
                        GradientStop { position: 0.4; color: dial.backgroundColor }
                        GradientStop { position: 0.48; color: Qt.darker(dial.backgroundColor, 1.2) }
                        GradientStop { position: 0.5; color: Qt.darker(dial.backgroundColor, 1.3) }
                        GradientStop { position: 0.52; color: Qt.darker(dial.backgroundColor, 1.2) }
                        GradientStop { position: 0.6; color: dial.backgroundColor }
                        GradientStop { position: 1.0; color: dial.backgroundColor }
                    }

                    source: Rectangle {
                        width: _knob.width
                        height: _knob.height
                        radius: width / 2
                        visible: false
                    }
                }

                layer.enabled: true
                layer.effect: DropShadow {
                    horizontalOffset: 0
                    verticalOffset: 2
                    radius: 12.0
                    samples: 25
                    color: "#a0000000"
                }
            }

            Rectangle {
                id: _knobInnerIdent
                anchors.fill: _knob
                anchors.margins: 10
                radius: width / 2
                color: "transparent"
                border.color: Qt.lighter(dial.backgroundColor, 1.5)
                border.width: 2
            }

            QQC2.Label {
                id: _label1
                anchors.centerIn: parent
                visible: false
                width: Math.min(90, _knob.width * 0.8)
                horizontalAlignment: Text.AlignHCenter
                fontSizeMode: Text.Fit
                minimumPointSize: 6
                wrapMode: Text.NoWrap
                font.pointSize: 20
                font.weight: Font.ExtraBold
                font.family: "Hack"
                font.letterSpacing: 2
                color: dial.foregroundColor
                padding: 4
                text: dial.value.toFixed(2)
            }
        }
    }
}
