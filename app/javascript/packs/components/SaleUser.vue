<template>
    <div>
        <div class="sale-user d-flex mt-2">
            <div class="mr-auto">
                <i class="fa fa-user-circle-o"></i> {{ user.fullname }}
            </div>

            <div>
                {{ this.time | dateFormat("DD/MM/YYYY h:mm") }}
            </div>
        </div>

        <div class="mt-2">
            <SaleCustomer></SaleCustomer>
        </div>

        <hr style="margin: 0.8rem -10px;">

        <div class="d-flex justify-content-between align-items-center mb-2">
            <h5 class="mb-0">{{ scannerOpen ? 'Scan the product code.' : ' ' }}</h5>
            <button v-if="!scannerOpen" type="button" class="btn btn-outline-secondary btn-sm" title="Scan QR" @click="openScanner">
                <i class="fa fa-qrcode"></i> Scan QR
            </button>
            <button v-else type="button" class="btn btn-outline-secondary btn-sm" @click="closeScanner">
                <i class="fa fa-times"></i> Close
            </button>
        </div>

        <QrScanner v-if="scannerOpen" @scan="lookupProduct" />
        <Payment v-else></Payment>

        <p v-if="scannerMessage" :class="scannerError ? 'text-danger' : 'text-success'" class="mt-2 mb-0">
            {{ scannerMessage }}
        </p>

        <hr style="margin: 0.8rem -10px;">

        <button class="btn btn-park btn-lg w-100 text-white" @click="checkout">
            <i class="fa fa-shopping-cart"></i>
            Payment
        </button>

        <b-modal id="modal-checkout-success" title="Payment" @ok="closeOrder">
            <p class="my-4 text-success">Do you want to close this invoice?</p>
        </b-modal>
    </div>
</template>

<script>
    import SaleCustomer from './SaleCustomer'
    import Payment from "./Payment"
    import QrScanner from './QrScanner'
    import axios from 'axios'
    import config from '../config'
    export default {
        name: "SaleUser",
        props: ['user'],
        data () {
            const time = Date.now()

            return {
                time: time,
                scannerOpen: false,
                scannerBusy: false,
                scannerError: false,
                scannerMessage: '',
                lastScannedCode: '',
                lastScannedAt: 0
            }
        },
        components: {
            Payment,
            SaleCustomer,
            QrScanner
        },
        methods: {
            openScanner() {
                this.scannerMessage = ''
                this.scannerError = false
                this.scannerOpen = true
            },
            closeScanner() {
                this.scannerOpen = false
                this.scannerBusy = false
                this.scannerMessage = ''
                this.lastScannedCode = ''
            },
            lookupProduct(rawCode) {
                const code = String(rawCode || '').trim()
                const now = Date.now()
                if (!code || this.scannerBusy || (code === this.lastScannedCode && now - this.lastScannedAt < 1500)) return

                this.lastScannedCode = code
                this.lastScannedAt = now
                this.scannerBusy = true
                this.scannerError = false
                this.scannerMessage = 'Looking for a product...'

                axios.get(config.PRODUCT_LOOKUP_PATH, { params: { code: code } }).then((response) => {
                    this.$store.dispatch('addItemToOrder', response.data)
                    this.scannerMessage = 'Added: ' + response.data.name
                }).catch(() => {
                    this.scannerError = true
                    this.scannerMessage = 'No products with this code were found: ' + code
                }).then(() => {
                    this.scannerBusy = false
                })
            },
            checkout() {
                this.$store.dispatch('checkout').then(() => {
                    this.$bvModal.show('modal-checkout-success')
                }).catch(error => {
                    const response = error.response || {}
                    const errors = response.data && response.data.errors
                    const message = errors ? Object.values(errors).join(', ') : error.message
                    alert(message || 'Không thể tạo hóa đơn. Vui lòng thử lại.')
                })
            },
            closeOrder() {
                this.$store.dispatch('closeCheckoutOrder')
            }
        }
    }
</script>

<style scoped lang="scss">
</style>