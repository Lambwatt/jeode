window.requestAnimFrame = (function(callback) {
        return window.requestAnimationFrame || window.webkitRequestAnimationFrame || window.mozRequestAnimationFrame || window.oRequestAnimationFrame || window.msRequestAnimationFrame ||
        function(callback) {
          window.setTimeout(callback, 1000 / 60);
        };
})();

var canvas = document.getElementById("canvas");
var context = canvas.getContext("2d");

var activeEntities = [];
var passiveEntities = [];

function addActiveEntity(e)
{
    acitveEntities.append(e);
}

function addPassiveEntity(e)
{
    passiveEntities.append(e);
}

