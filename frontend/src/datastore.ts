import { reactive } from 'vue'

export var gruntState = reactive({
    x: 500,
    y: 500,
    animationName: '',
})

export var controller = reactive({
    up: false,
    down: false,
    right: false,
    left: false,
})