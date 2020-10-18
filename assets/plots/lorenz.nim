import plotly
import chroma
import jsffi
import dom
import json
import sequtils, strutils
import basic3d, math
import deques

let
  a = 10.0 # Prandtl
  b = 28.0 # Rayleigh
  c = 8.0/3.0
  min_distance = 0.5

var
  current = vector3d(1.0, 1.0, 1.0)
  next    = vector3d(0.0, 0.0, 0.0)
  last    = vector3d(0.0, 0.0, 0.0)
  time_coefficient = 0.005

proc euclidian_distance(a, b: Vector3d): float =
  return cbrt(pow(a.x - b.x, 2) + pow(a.y - b.y, 2) + pow(a.z - b.z, 2))

proc next_lorenz(): Vector3d =
  next.x = a * (current.y - current.x)
  next.y = current.x * (b - current.z) - current.y
  next.z = current.x * current.y - c * current.z
  current += next * time_coefficient
  return current

proc lorenz_animation*(p: Plot) =
  let
    data   = parseJsonToJs(parseTraces(p.traces))
    layout = parseJsonToJs($(% p.layout))
    plotly = newPlotly()
  plotly.newPlot("lorenz", data, layout)

  proc loop() =
    next = next_lorenz()
    while euclidian_distance(last, next) < min_distance:
      next = next_lorenz()
      time_coefficient = min(0.01, time_coefficient*2)
    p.traces[0].xs.add(next.x)
    p.traces[0].ys.add(next.z)

    # draw
    let dataNew = parseJsonToJs(parseTraces(p.traces))
    plotly.react("lorenz", dataNew, layout)

    # prepare for next iteration
    # awful ringbuffer
    var max_size = 1000
    if len(p.traces[0].xs) > max_size:
      p.traces[0].xs.delete(0)
      p.traces[0].ys.delete(0)
      p.traces[0].zs.delete(0)
    time_coefficient = 0.005
    last = next

  discard window.setInterval(loop, 100)

when isMainModule:
  let
    d1 = Trace[float](mode: PlotMode.LinesMarkers, `type`: PlotType.Scatter,
      name: "XZ-Pane")
  d1.marker = Marker[float](size: @[1.0], color: @[Color(r:0.5, g:0.5, b:0.5)])

  let
    layout = Layout(title: "Lorenz Attractor",
                    xaxis: Axis(title:"X"),
                    yaxis: Axis(title: "Y"),
                    autosize: false)
    p = Plot[float](layout: layout, traces: @[d1])

p.lorenz_animation()
