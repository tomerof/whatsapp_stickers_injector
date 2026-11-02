package com.liatofer.whatsapp_stickers_injector;

import androidx.annotation.NonNull;

/**
 * Minimal RIFF/WebP header reader. It extracts only what WhatsApp's sticker rules need: whether the
 * file is animated, the canvas size, the number of frames and each frame's duration. No pixel data
 * is decoded, so no external library is required.
 *
 * Layout reference (https://developers.google.com/speed/webp/docs/riff_container):
 * <pre>
 * "RIFF" size "WEBP" { fourcc(4) size(4, little endian) payload (padded to an even length) }*
 * VP8X payload: flags(1, 0x02 = animation) reserved(3) canvasWidth-1(3) canvasHeight-1(3)
 * ANMF payload: x/2(3) y/2(3) width-1(3) height-1(3) duration_ms(3) flags(1) frame data
 * </pre>
 */
final class WebPInfo {
    private static final int VP8X_ANIMATION_FLAG = 0x02;

    /** True if the file is a WebP container with the animation flag set. */
    final boolean animated;
    /** Canvas width in pixels, or -1 when the file has no VP8X header. */
    final int canvasWidth;
    /** Canvas height in pixels, or -1 when the file has no VP8X header. */
    final int canvasHeight;
    /** Number of ANMF (animation frame) chunks found. */
    final int frameCount;
    /** Sum of all frame durations in milliseconds. */
    final long totalDurationMs;
    /** Shortest single frame duration in milliseconds, or 0 if there are no frames. */
    final int minFrameDurationMs;

    private WebPInfo(boolean animated, int canvasWidth, int canvasHeight, int frameCount, long totalDurationMs,
            int minFrameDurationMs) {
        this.animated = animated;
        this.canvasWidth = canvasWidth;
        this.canvasHeight = canvasHeight;
        this.frameCount = frameCount;
        this.totalDurationMs = totalDurationMs;
        this.minFrameDurationMs = minFrameDurationMs;
    }

    /**
     * Reads the WebP headers. Data that is not a WebP container, or that is truncated, is reported
     * as a static image rather than throwing, matching how this plugin treated unknown data before.
     */
    @NonNull
    static WebPInfo parse(@NonNull byte[] data) {
        if (data.length < 12 || !fourCc(data, 0, "RIFF") || !fourCc(data, 8, "WEBP")) {
            return new WebPInfo(false, -1, -1, 0, 0, 0);
        }
        boolean animated = false;
        int width = -1;
        int height = -1;
        int frames = 0;
        long total = 0;
        int min = Integer.MAX_VALUE;

        int pos = 12;
        while (pos + 8 <= data.length) {
            long size = readLe(data, pos + 4, 4);
            int payload = pos + 8;
            if (fourCc(data, pos, "VP8X") && payload + 10 <= data.length) {
                animated = (data[payload] & VP8X_ANIMATION_FLAG) != 0;
                width = (int) readLe(data, payload + 4, 3) + 1;
                height = (int) readLe(data, payload + 7, 3) + 1;
            } else if (fourCc(data, pos, "ANMF") && payload + 16 <= data.length) {
                int duration = (int) readLe(data, payload + 12, 3);
                frames++;
                total += duration;
                if (duration < min) {
                    min = duration;
                }
            }
            long next = payload + size + (size & 1);
            if (next > data.length) {
                break;
            }
            pos = (int) next;
        }
        return new WebPInfo(animated, width, height, frames, total, frames == 0 ? 0 : min);
    }

    private static boolean fourCc(byte[] data, int offset, String tag) {
        for (int i = 0; i < 4; i++) {
            if (data[offset + i] != (byte) tag.charAt(i)) {
                return false;
            }
        }
        return true;
    }

    private static long readLe(byte[] data, int offset, int length) {
        long value = 0;
        for (int i = length - 1; i >= 0; i--) {
            value = (value << 8) | (data[offset + i] & 0xFF);
        }
        return value;
    }
}
