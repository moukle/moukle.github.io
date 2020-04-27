import dom

proc onLoad(event: Event) =
  let p = document.createElement("p")
  p.innerHTML = "Click me!"
  p.style.fontFamily = "Helvetica"
  p.style.color = "red"

  p.addEventListener("click",
    proc (event: Event) =
      window.alert("Hello World!")
  )

  document.body.appendChild(p)

window.onload = onLoad
