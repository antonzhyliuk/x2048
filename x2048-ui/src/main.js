import Vue from 'vue'
import App from './App.vue'
import channel from './game-channel'

Vue.config.productionTip = false

new Vue({
  render: h => h(App),
}).$mount('#app')

window.channel = channel
