import { reactive } from 'vue'

export var gruntState = reactive({
    x: 165,
    y: 150,
    animationName: '',
})

export var controller = reactive({
    up: false,
    down: false,
    right: false,
    left: false,
})

export var weedStats = reactive({
    number_of_harvests: 0,
    total_yield: 0,
    idx: 0
})