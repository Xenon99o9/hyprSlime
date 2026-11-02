import QtQuick

Item {
    id: root

    implicitWidth: 120
    implicitHeight: 40

    property real chamfer: 10
    property color fillColor: SageState.bgSurface
    property color borderColor: SageState.primaryAccent
    property color innerColor: SageState.secondaryAccent
    property real borderWidth: 1.5
    property bool innerBorder: true
    property real innerAlpha: 0.38
    property bool cornerDiamonds: false
    property bool showMagicCircle: false
    property real magicCircleAlpha: 0.08
    property real rotationAngle: 0

    onFillColorChanged: frameCanvas.requestPaint()
    onBorderColorChanged: frameCanvas.requestPaint()
    onInnerColorChanged: frameCanvas.requestPaint()
    onBorderWidthChanged: frameCanvas.requestPaint()
    onInnerBorderChanged: frameCanvas.requestPaint()
    onInnerAlphaChanged: frameCanvas.requestPaint()
    onChamferChanged: frameCanvas.requestPaint()
    onWidthChanged: frameCanvas.requestPaint()
    onHeightChanged: frameCanvas.requestPaint()

    NumberAnimation on rotationAngle {
        running: root.showMagicCircle && root.visible
        from: 0
        to: 360
        duration: 48000
        loops: Animation.Infinite
    }

    onRotationAngleChanged: {
        if (root.showMagicCircle) {
            sealCanvas.requestPaint();
        }
    }

    Canvas {
        id: sealCanvas
        anchors.fill: parent
        visible: root.showMagicCircle
        onPaint: {
            const ctx = getContext("2d");
            ctx.reset();
            const w = width;
            const h = height;
            if (w <= 10 || h <= 10) return;

            const cx = w * 0.5;
            const cy = h * 0.5;
            const r = Math.min(w, h) * 0.43;
            const rad = root.rotationAngle * Math.PI / 180.0;

            ctx.save();
            ctx.translate(cx, cy);
            ctx.rotate(rad);

            ctx.strokeStyle = Qt.rgba(root.borderColor.r, root.borderColor.g, root.borderColor.b, root.magicCircleAlpha);
            ctx.lineWidth = 1.4;

            ctx.beginPath();
            ctx.arc(0, 0, r, 0, Math.PI * 2);
            ctx.stroke();

            ctx.strokeStyle = Qt.rgba(root.innerColor.r, root.innerColor.g, root.innerColor.b, root.magicCircleAlpha * 1.15);
            ctx.beginPath();
            ctx.arc(0, 0, r * 0.91, 0, Math.PI * 2);
            ctx.stroke();

            for (let s = 0; s < 2; ++s) {
                const offset = s * (Math.PI / 4.0);
                ctx.beginPath();
                for (let i = 0; i < 4; ++i) {
                    const a = offset + i * (Math.PI / 2.0);
                    const px = r * 0.91 * Math.cos(a);
                    const py = r * 0.91 * Math.sin(a);
                    if (i === 0) ctx.moveTo(px, py);
                    else ctx.lineTo(px, py);
                }
                ctx.closePath();
                ctx.stroke();
            }

            ctx.strokeStyle = Qt.rgba(root.borderColor.r, root.borderColor.g, root.borderColor.b, root.magicCircleAlpha * 0.9);
            ctx.beginPath();
            for (let i = 0; i < 8; ++i) {
                const a = i * (Math.PI / 4.0);
                const px = r * 0.54 * Math.cos(a);
                const py = r * 0.54 * Math.sin(a);
                if (i === 0) ctx.moveTo(px, py);
                else ctx.lineTo(px, py);
            }
            ctx.closePath();
            ctx.stroke();

            ctx.beginPath();
            ctx.arc(0, 0, r * 0.34, 0, Math.PI * 2);
            ctx.stroke();

            ctx.restore();
        }
    }

    Canvas {
        id: frameCanvas
        anchors.fill: parent
        onPaint: {
            const ctx = getContext("2d");
            ctx.reset();
            const w = width;
            const h = height;
            if (w <= 4 || h <= 4) return;

            const c = Math.min(root.chamfer, Math.min(w, h) * 0.35);
            const pad = root.borderWidth * 0.6;

            function traceOctagon(inset, ch) {
                ctx.beginPath();
                ctx.moveTo(inset + ch, inset);
                ctx.lineTo(w - inset - ch, inset);
                ctx.lineTo(w - inset, inset + ch);
                ctx.lineTo(w - inset, h - inset - ch);
                ctx.lineTo(w - inset - ch, h - inset);
                ctx.lineTo(inset + ch, h - inset);
                ctx.lineTo(inset, h - inset - ch);
                ctx.lineTo(inset, inset + ch);
                ctx.closePath();
            }

            traceOctagon(pad, c);
            ctx.fillStyle = root.fillColor;
            ctx.fill();

            ctx.lineWidth = root.borderWidth;
            ctx.strokeStyle = root.borderColor;
            ctx.stroke();

            if (root.innerBorder && w > 24 && h > 20) {
                const inPad = pad + 3.5;
                const inC = Math.max(2, c - 2.0);
                traceOctagon(inPad, inC);
                ctx.lineWidth = 1.0;
                ctx.strokeStyle = Qt.rgba(root.innerColor.r, root.innerColor.g, root.innerColor.b, root.innerAlpha);
                ctx.stroke();
            }

            if (root.cornerDiamonds && w > 80 && h > 40) {
                ctx.fillStyle = root.innerColor;
                const dSize = 3.2;
                const pts = [
                    [pad + c + 6, pad + 3.5],
                    [w - pad - c - 6, pad + 3.5],
                    [pad + c + 6, h - pad - 3.5],
                    [w - pad - c - 6, h - pad - 3.5]
                ];
                for (let i = 0; i < pts.length; ++i) {
                    const px = pts[i][0];
                    const py = pts[i][1];
                    ctx.beginPath();
                    ctx.moveTo(px, py - dSize);
                    ctx.lineTo(px + dSize, py);
                    ctx.lineTo(px, py + dSize);
                    ctx.lineTo(px - dSize, py);
                    ctx.closePath();
                    ctx.fill();
                }
            }
        }
    }
}
