class App.ImageService

  @resizeForAvatar: (dataURL, x, y, callback) =>
    if @checkUrl(dataURL)
      callback(dataURL)
    else
      @resize(dataURL, x, y, 2, 'image/jpeg', 0.7, callback)

  @resizeForApp: (dataURL, x, y, callback) =>
    if @checkUrl(dataURL)
      callback(dataURL)
    else
      @resize(dataURL, x, y, 2, 'image/png', 0.7, callback)

  @resize: (dataURL, x = 'auto', y = 'auto', sizeFactor = 1, type, quallity, callback, force = true) ->

    # load image from data url
    imageObject = new Image()
    imageObject.onload = ->
      imageWidth  = imageObject.width
      imageHeight = imageObject.height
      console.log('ImageService', 'current size', imageWidth, imageHeight)
      console.log('ImageService', 'sizeFactor', sizeFactor)
      if y is 'auto' && x is 'auto'
        x = imageWidth
        y = imageHeight

      # set max x/y
      if x isnt 'auto' && x > imageWidth
        x = imageWidth

      if y isnt 'auto' && y > imageHeight
        y = imageHeight

      # get auto dimensions
      if y is 'auto'# && (y * factor) >= imageHeight
        factor = imageWidth / x
        y = imageHeight / factor

      if x is 'auto'# && (y * factor) >= imageWidth
        factor = imageWidth / y
        x = imageHeight / factor

      canvas = document.createElement('canvas')

      # check if resize is needed
      resize = false
      if (x < imageWidth && (x * sizeFactor < imageWidth)) || (y < imageHeight && (y * sizeFactor < imageHeight))
        resize = true
        x = x * sizeFactor
        y = y * sizeFactor

        # set dimensions
        canvas.width  = x
        canvas.height = y

        # draw image on canvas and set image dimensions
        context = canvas.getContext('2d')
        context.drawImage(imageObject, 0, 0, x, y)

      else

        # set dimensions
        canvas.width  = imageWidth
        canvas.height = imageHeight

        # draw image on canvas and set image dimensions
        context = canvas.getContext('2d')
        context.drawImage(imageObject, 0, 0, imageWidth, imageHeight)

      # set quallity based on image size
      if quallity == 'auto'
        if x < 200 && y < 200
          quallity = 1
        else if x < 400 && y < 400
          quallity = 0.9
        else if x < 600 && y < 600
          quallity = 0.8
        else if x < 900 && y < 900
          quallity = 0.7
        else
          quallity = 0.6

      # execute callback with resized image
      newDataUrl = canvas.toDataURL(type, quallity)
      if resize
        console.log('ImageService', 'resize', x/sizeFactor, y/sizeFactor, quallity, (newDataUrl.length * 0.75)/1024/1024, 'in mb')
        callback(newDataUrl, x/sizeFactor, y/sizeFactor, true)
        return
      console.log('ImageService', 'no resize', x, y, quallity, (newDataUrl.length * 0.75)/1024/1024, 'in mb')
      callback(newDataUrl, x, y, false)

    # load image from data url
    imageObject.src = dataURL

  @checkUrl: (dataURL) ->
    ignore = /\.svg$/i
    ignore.test(dataURL)
