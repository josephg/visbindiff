canvas = document.getElementById('canvas')
data = []

abs = (x) -> if x > 0 then x else -x

range = (arr) ->
  min = 255
  max = 0
  i = 0
  while i < arr.length
    if arr[i] < min
      min = arr[i]
    if arr[i] > max
      max = arr[i]
    i++

  min: min
  max: max

maybeDone = ->
  return unless data[0] || data[1]
  data[0] ||= data[1]
  data[1] ||= data[0]

  console.log 'got both'
  width = canvas.width = canvas.style.width = data[0].length
  height = canvas.height = canvas.style.height = data[1].length
  ctx = canvas.getContext('2d')
  image = ctx.createImageData(width, height)
  if !image
    window.alert 'too big!'
    return
  console.log 'scanning...'
  imagedata = image.data
  r0 = range(data[0])
  r1 = range(data[1])
  mult = 255 / Math.max(abs(r0.max - r1.min), abs(r1.max - r0.min))
  console.log 'rendering...'

  for xv,x in data[0]
    for yv,y in data[1]
      base = (x + y * width) * 4
      v = Math.abs(xv - yv) * mult | 0
      if xv == 0 and v == 0
        imagedata[base] = 0
        imagedata[base + 1] = 255
        imagedata[base + 2] = 0
      else if v == 0
        # Red
        imagedata[base] = 255
        imagedata[base + 1] = 0
        imagedata[base + 2] = 0
      else
        # Grey
        imagedata[base] = imagedata[base + 1] = imagedata[base + 2] = v
      imagedata[base + 3] = 255

  ctx.putImageData image, 0, 0

loadFrom = (num) ->
  el = document.getElementById('f' + num)

  el.onchange = ->
    fr = new FileReader

    fr.onloadend = ->
      console.log 'load end'
      data[num] = new Uint8Array(fr.result)
      maybeDone()
      return

    if el.files.length
      fr.readAsArrayBuffer el.files[0]
    return

  return

loadFrom 0
loadFrom 1

stringNear = (d, idx, width) ->
  width = width or 10
  if !data[d]
    return ''
  str = ''
  i = idx - width
  while i <= idx + width and i < data[d].length
    str += String.fromCharCode(data[d][i])
    i++
  JSON.stringify str

popoverEl = document.getElementById('popover')

canvas.onmousemove = (e) ->
  x = e.offsetX
  y = e.offsetY
  #e.offsetX, e.offsetY
  popoverEl.style.left = x + 25
  popoverEl.style.top = y + 45
  if data[0]
    v0 = data[0][x]
    s0 = stringNear(0, x)
  if data[1]
    v1 = data[1][x]
    s1 = stringNear(1, y)
  popoverEl.innerText = '(' + x + ',' + y + ') ' + v0 + '(\'' + s0 + '\') vs ' + v1 + '(\'' + s1 + '\')'
  popoverEl.style.display = 'initial'
  return

canvas.onmouseleave = ->
  popoverEl.style.display = 'none'
  return

canvas.onmouseenter = ->
  popoverEl.style.display = 'initial'
  return

