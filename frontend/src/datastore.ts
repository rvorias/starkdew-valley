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

export var plantState = reactive({
    stage: 2,
})

export var weedStats = reactive({
    number_of_harvests: 0,
    total_yield: 0,
})