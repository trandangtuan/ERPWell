import axios from 'axios'
import jsQR from 'jsqr'

(function () {
    let stream = null
    let animationFrame = null
    let lastCode = ''
    let lastCodeAt = 0

    function stopScanner () {
        if (animationFrame) {
            window.cancelAnimationFrame(animationFrame)
            animationFrame = null
        }
        if (stream) {
            stream.getTracks().forEach(track => track.stop())
            stream = null
        }
    }

    function scanFrame () {
        const video = document.getElementById('purchase-qr-video')
        const canvas = document.getElementById('purchase-qr-canvas')
        if (!stream || !video || !canvas) return

        if (video.readyState >= 2 && video.videoWidth > 0) {
            canvas.width = video.videoWidth
            canvas.height = video.videoHeight
            const context = canvas.getContext('2d')
            context.drawImage(video, 0, 0, canvas.width, canvas.height)
            const image = context.getImageData(0, 0, canvas.width, canvas.height)
            const result = jsQR(image.data, image.width, image.height)
            if (result && result.data) {
                const code = result.data.trim()
                const now = Date.now()
                if (code && (code !== lastCode || now - lastCodeAt > 1500)) {
                    lastCode = code
                    lastCodeAt = now
                    lookupProduct(code)
                }
            }
        }

        animationFrame = window.requestAnimationFrame(scanFrame)
    }

    function lookupProduct (code) {
        const message = document.getElementById('purchase-qr-message')
        if (message) message.textContent = 'Đang tìm sản phẩm...'

        axios.get('/manage/products/lookup.json', { params: { code: code } }).then(response => {
            if (window.addPurchaseProduct) window.addPurchaseProduct(response.data)
            if (message) {
                message.className = 'text-success mt-2 mb-0'
                message.textContent = 'Added: ' + response.data.name
            }
        }).catch(() => {
            if (message) {
                message.className = 'text-danger mt-2 mb-0'
                message.textContent = 'No products with this code were found: ' + code
            }
        })
    }

    function openScanner () {
        const modal = document.getElementById('purchase-qr-modal')
        const message = document.getElementById('purchase-qr-message')
        if (!modal) return
        modal.style.display = 'flex'
        if (message) {
            message.className = 'text-muted mt-2 mb-0'
            message.textContent = ''
        }

        if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
            if (message) message.textContent = 'Trình duyệt không hỗ trợ camera. Vui lòng nhập mã thủ công.'
            return
        }

        navigator.mediaDevices.getUserMedia({ video: { facingMode: { ideal: 'environment' } }, audio: false }).then(cameraStream => {
            stream = cameraStream
            const video = document.getElementById('purchase-qr-video')
            video.srcObject = stream
            return video.play()
        }).then(scanFrame).catch(() => {
            if (message) message.textContent = 'Không thể truy cập camera. Vui lòng cấp quyền hoặc nhập mã thủ công.'
        })
    }

    function closeScanner () {
        stopScanner()
        const modal = document.getElementById('purchase-qr-modal')
        if (modal) modal.style.display = 'none'
    }

    document.addEventListener('turbolinks:load', function () {
        const openButton = document.getElementById('purchase-qr-open')
        const closeButton = document.getElementById('purchase-qr-close')
        const modal = document.getElementById('purchase-qr-modal')
        if (openButton) openButton.addEventListener('click', openScanner)
        if (closeButton) closeButton.addEventListener('click', closeScanner)
        if (modal) modal.addEventListener('click', event => {
            if (event.target === modal) closeScanner()
        })
    })

    window.addEventListener('beforeunload', stopScanner)
})()
