class window.ThreejsSimplifier
  renderer: null
  camera: null
  scene: null
  preview: null
  mesh: null
  original_geometry: null
  onGeometryChange: null
  controls: null

  constructor: (threejs_selector, onGeometryChange)->
    @renderer = new THREE.WebGLRenderer(
      preserveDrawingBuffer: true
      useDevicePixelRatio: false
      devicePixelRatio: 1
      alpha: true,
      antialias: true
    )
    @preview = $(threejs_selector)
    @preview.append(@renderer.domElement)
    @camera = new THREE.PerspectiveCamera(45, @width()/@height(), 0.1, 10000)
    @scene = new THREE.Scene()
    @scene.add(@camera)
    @autosize()
    @renderer.setClearColor(0x000000, 0)
    @simplifyModifier = new THREE.SimplifyModifier()
    @material = new THREE.MeshPhongMaterial(color: '#fff')
    @meshmaterials = [
      new THREE.MeshPhongMaterial(color: '#fff', shading: THREE.FlatShading),
      new THREE.MeshBasicMaterial(color: 0x405040, wireframe: true, opacity: 0.8, transparent: true)
    ]
    @onGeometryChange = onGeometryChange
    @loadDefaultModel()
    @setupCameraAndControls()
    @setupLight()
    @animate()

  simplifyMeshTo: (vertices)->
    return if $('.loader').hasClass('loader')
    if @mesh.children[0].geometry.vertices.length == vertices
      console.log('same vertices as requested')
    else
      console.log('simplifying', @original_geometry.vertices.length, 'to', vertices)
      $('.loader').addClass('loader') if !@isFastProcessing()
      original_geometry = @original_geometry.clone()
      simplified_geometry = @simplifyModifier.modify(original_geometry, vertices)
      simplified_geometry.computeFaceNormals()
      @createMesh(simplified_geometry, false)

  createMesh: (geometry, with_original=true)->
    if @mesh
      @scene.remove(@mesh)
      @mesh = null

    geometry = new THREE.Geometry().fromBufferGeometry(geometry) if geometry.isBufferGeometry
    geometry.center()
    geometry.mergeVertices()
    geometry.computeFaceNormals()
    geometry.computeFlatVertexNormals()
    if with_original
      @original_geometry = geometry.clone()
      @onGeometryChange(geometry.vertices.length) if typeof @onGeometryChange is 'function'
    @mesh = new THREE.SceneUtils.createMultiMaterialObject(geometry, @meshmaterials)
    @mesh.castShadow = true
    @mesh.receiveShadow = true
    @scene.add(@mesh)
    $('#loader').removeClass('loader')

  isFastProcessing: ->
    !!@original_geometry?.vertices?.length > 8000

  logSlider: (position, maxp=1000, minp=1)->
    position = parseInt(position)
    maxp = parseInt(maxp)
    minp = parseInt(minp)
    minv = Math.log(50)
    maxv = Math.log(@original_geometry.vertices.length)
    scale = (maxv-minv) / (maxp-minp)
    parseInt(Math.exp(minv + scale*(position-minp)))

  loadDefaultModel: ->
    $('#loader').addClass('loader')
    geometry = new THREE.RabbitGeometry()
    geometry.rotateX(Math.PI/2)
    @smothenGeometry(geometry, 2)
    geometry.scale(100, 100, 100)
    @createMesh(geometry)

  smothenGeometry: (geometry, level=2)->
    modifier = new THREE.SubdivisionModifier(level)
    modifier.modify(geometry)

  parseSTL: (arrayBuffer)->
    $('#loader').addClass('loader')
    setTimeout((=> @createMesh(new THREE.STLLoader().parse(arrayBuffer))), 50)

  exportMesh: ->
    return new Blob([new THREE.STLBinaryExporter().parse(@mesh.children[0])], {type: "application/octet-stream"})

  setupCameraAndControls: ->
    @camera.updateProjectionMatrix()
    @camera.lookAt(new THREE.Vector3(0, 25, 0))
    @camera.up.set(0, 0, 1)
    @controls = new THREE.OrbitControls(@camera, @renderer.domElement)
    @controls.autoRotate = true
    @camera.position.set(-135, 75, 75)
    @controls.update()

  setupLight: ->
    hemiLight = new THREE.HemisphereLight( 0xffffff, 0xffffff, 0.6 )
    hemiLight.color.setHSL( 0.6, 1, 0.6 )
    hemiLight.groundColor.setHSL( 0.095, 1, 0.75 )
    hemiLight.position.set( 0, 50, 0 )
    @scene.add( hemiLight )

    dirLight = new THREE.DirectionalLight( 0xffffff, 1 )
    dirLight.color.setHSL( 0.1, 1, 0.95 )
    dirLight.position.set( 1, -1.75, 1 )
    dirLight.position.multiplyScalar( 30 )
    @scene.add( dirLight )

    dirLight.castShadow = true
    dirLight.shadow.mapSize.width = 2048
    dirLight.shadow.mapSize.height = 2048
    d = 50
    dirLight.shadow.camera.left = -d
    dirLight.shadow.camera.right = d
    dirLight.shadow.camera.top = d
    dirLight.shadow.camera.bottom = -d
    dirLight.shadow.camera.far = 3500
    dirLight.shadow.bias = -0.0001

  autosize: ->
    @renderer.setSize(@width(), @height())
    @camera.aspect = @width() / @height()
    @camera.updateProjectionMatrix()

  width: ->
    borderRight = parseInt(@preview.css('border-right-width'))
    borderLeft = parseInt(@preview.css('border-left-width'))
    @preview.parent().width() - borderLeft - borderRight

  height: ->
    borderTop = parseInt(@preview.css('border-top-width'))
    borderBottom = parseInt(@preview.css('border-bottom-width'))
    @preview.parent().height() - borderTop - borderBottom

  animate: ->
    @render()
    window.requestAnimationFrame(=> @animate())

  render: ->
    @controls.update()
    @renderer.render(@scene, @camera)

$().ready ->
  window.ThreejsApp = new ThreejsSimplifier '#threejs', (vertices)->
    $('#vertices_number_input').attr('value', vertices)

  $(window).resize -> ThreejsApp.autosize()

  simplifyNow = (e)->
    vertices = ThreejsApp.logSlider(e.target.value, e.target.max, e.target.min)
    $('#vertices_number_input').attr('value', vertices)
    setTimeout((-> ThreejsApp.simplifyMeshTo(vertices)), 50)

  debounceSimplify = debounce((e)-> simplifyNow(e))

  $('#vertices_range_input').on 'mousemove mouseover mousedown mouseup touch change', (e)->
    if ThreejsApp.isFastProcessing()
      debounceSimplify(e)
    else
      simplifyNow(e)

  autoRotateOn = debounce((-> ThreejsApp.controls.autoRotate = true), 10*1000)
  $('#threejs canvas').on 'click', ->
    ThreejsApp.controls.autoRotate = false
    autoRotateOn()

  file_input = document.getElementById('file_input')
  $(file_input).on 'change', (e)->
    $('.jumbotron').addClass('hidden')
    document.getElementById('vertices_range_input').value = 1000
    if e.target.files.length
      fr = new FileReader()
      fr.onloadend = (evt)=>
        ThreejsApp.parseSTL(evt.target.result)
      fr.readAsArrayBuffer(e.target.files[0])

  $('#save').on 'click', ->
    blob = ThreejsApp.exportMesh()
    if file_input?.files?.length && file_input.files[0]?.name?.length
      file_name = file_input.files[0].name.slice(0, -4)
    else
      file_name = ''
    file_name += '3dless_com_simplified.stl'
    window.saveAs(blob,  file_name)

# TODO:
# add material wireframe