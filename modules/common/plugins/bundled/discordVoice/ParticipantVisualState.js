.pragma library

// Repeater delegates are rebuilt when the bridge publishes a fresh participant
// array. Retain only the last shape per Discord user so a replacement delegate
// can animate from what was actually on screen instead of appearing in its new
// state immediately.
var shapes = Object.create(null)

function previous(userId, fallback) {
    return userId && shapes[userId] !== undefined ? shapes[userId] : fallback
}

function remember(userId, shape) {
    if (userId)
        shapes[userId] = shape
}
