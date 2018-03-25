class window.ThreejsSimplifier
  renderer: null
  camera: null
  scene: null
  preview: null

  constructor: (threejs_selector)->
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
    @renderer.setSize(@width(), @height())
    @renderer.shadowMap.enabled = parseInt(navigator.hardwareConcurrency || '2') > 3
    @renderer.setClearColor(0x000000, 0)
    @setupCameraAndControls()
    @setupLight()
    @material = new THREE.MeshPhongMaterial(color: '#fff')
    new THREE.STLLoader().load 'models/3DBenchy.stl', (geometry)=>
      geometry.center()
      @mesh = new THREE.Mesh(geometry, @material)
      @mesh.rotation.x = -Math.PI/2

      @mesh.castShadow = true
      @mesh.receiveShadow = true

      @scene.add(@mesh)
    @animate()

  setupCameraAndControls: ->
    @camera.updateProjectionMatrix()
    @camera.lookAt(new THREE.Vector3(0, 25, 0))
    @controls = new THREE.OrbitControls(@camera, @renderer.domElement)
    @camera.position.set(-135, 75, -135)
    @controls.update()

  setupLight: ->
    hemiLight = new THREE.HemisphereLight( 0xffffff, 0xffffff, 0.6 )
    hemiLight.color.setHSL( 0.6, 1, 0.6 )
    hemiLight.groundColor.setHSL( 0.095, 1, 0.75 )
    hemiLight.position.set( 0, 50, 0 )
    @scene.add( hemiLight )

    dirLight = new THREE.DirectionalLight( 0xffffff, 1 )
    dirLight.color.setHSL( 0.1, 1, 0.95 )
    dirLight.position.set( -1, 1.75, 1 )
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
    @renderer.render(@scene, @camera)

