<template>
    <div class="qr-scanner">
        <video style="width:100%;height:200px" ref="video" class="qr-scanner-video" autoplay muted playsinline></video>
        <canvas ref="canvas" class="d-none"></canvas>
        <p v-if="error" class="text-danger mb-2">{{ error }}</p>
        <p v-else-if="!ready" class="text-muted mb-2">Open camera...</p>
        <input
            ref="manualCode"
            v-model.trim="manualCode"
            type="text"
            class="form-control form-control-sm"
            placeholder="Enter product code"
            @keyup.enter="submitManualCode"
        >
        <button type="button" class="btn btn-primary btn-sm mt-2" :disabled="!manualCode" @click="submitManualCode">
            <i class="fa fa-search"></i> Search
        </button>
    </div>
</template>

<script>
    import jsQR from 'jsqr'

    export default {
        name: 'QrScanner',
        data: () => ({
            stream: null,
            animationFrame: null,
            ready: false,
            error: '',
            manualCode: '',
            lastResult: '',
            lastResultAt: 0
        }),
        mounted () {
            this.start()
        },
        beforeDestroy () {
            this.stop()
        },
        methods: {
            async start () {
                if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
                    this.error = 'Trình duyệt không hỗ trợ camera. Vui lòng nhập mã sản phẩm.'
                    return
                }

                try {
                    this.stream = await navigator.mediaDevices.getUserMedia({
                        video: { facingMode: { ideal: 'environment' } },
                        audio: false
                    })
                    this.$refs.video.srcObject = this.stream
                    await this.$refs.video.play()
                    this.ready = true
                    this.scanFrame()
                } catch (error) {
                    this.error = 'Không thể truy cập camera. Vui lòng cấp quyền hoặc nhập mã sản phẩm.'
                }
            },
            scanFrame () {
                if (!this.stream || !this.ready) return

                const video = this.$refs.video
                if (video.readyState >= 2 && video.videoWidth > 0) {
                    const canvas = this.$refs.canvas
                    canvas.width = video.videoWidth
                    canvas.height = video.videoHeight
                    const context = canvas.getContext('2d')
                    context.drawImage(video, 0, 0, canvas.width, canvas.height)
                    const image = context.getImageData(0, 0, canvas.width, canvas.height)
                    const result = jsQR(image.data, image.width, image.height)
                    if (result && result.data) {
                        this.lastResultAt = Date.now()
                        if (result.data !== this.lastResult) {
                            this.lastResult = result.data
                            this.$emit('scan', result.data)
                        }
                    } else if (this.lastResult && Date.now() - this.lastResultAt > 800) {
                        this.lastResult = ''
                    }
                }

                this.animationFrame = window.requestAnimationFrame(this.scanFrame)
            },
            submitManualCode () {
                if (this.manualCode) {
                    this.$emit('scan', this.manualCode)
                    this.manualCode = ''
                }
            },
            stop () {
                if (this.animationFrame) {
                    window.cancelAnimationFrame(this.animationFrame)
                    this.animationFrame = null
                }
                if (this.stream) {
                    this.stream.getTracks().forEach(track => track.stop())
                    this.stream = null
                }
                this.ready = false
            }
        }
    }
</script>

<style scoped>
    .qr-scanner {
        max-width: 280px;
        margin: 0 auto;
    }

    .qr-scanner-video {
        display: block;
        width: 100%;
        max-height: 180px;
        background: #111;
        object-fit: contain;
    }
</style>
