/**
 * -------------------------------------------------
 * copyright (c) 2012 www.romatica.com
 * @author itoz
 * -------------------------------------------------
 * 
 * [Alternativa3D]
 * @see https://github.com/AlternativaPlatform/Alternativa3D
 * 
 * [AlternativaTemplate Class]
 * @see http://www.libspark.org/svn/as3/AlternativaTemplate/
 */
package 
{
    import alternativa.Alternativa3D;
    import alternativa.engine3d.core.Object3D;
    import alternativa.engine3d.lights.AmbientLight;
    import alternativa.engine3d.lights.DirectionalLight;
    import alternativa.engine3d.lights.OmniLight;
    import alternativa.engine3d.loaders.ParserCollada;
    import alternativa.engine3d.materials.EnvironmentMaterial;
    import alternativa.engine3d.materials.StandardMaterial;
    import alternativa.engine3d.objects.Mesh;
    import alternativa.engine3d.primitives.Plane;
    import alternativa.engine3d.resources.BitmapCubeTextureResource;
    import alternativa.engine3d.resources.BitmapTextureResource;
    import alternativa.engine3d.resources.TextureResource;

    import org.libspark.alternativa3d.view.AlternativaTemplate;

    import flash.text.TextField;
    import flash.text.TextFieldAutoSize;
    import flash.text.TextFormat;
    import flash.utils.getTimer;

    [SWF(backgroundColor="#000000", frameRate="60", width="800", height="480")]
    /**
     * DAE Model Sample
     */
    public class OctcatAlternativa3D extends AlternativaTemplate
    {
        //----------------------------------
        //  モデル用
        //----------------------------------
        [Embed(source="../assets/octcat_model.dae", mimeType="application/octet-stream")] private var MAINMODEL : Class;
        [Embed(source="../assets/octcat.png")] private var MAINTEXTURE : Class;
        [Embed(source="../assets/octcat_bump.png")] private var BUMPTEXTURE : Class;
        [Embed(source="../assets/octcat_specular.png")] private var SPECULARTEXTURE : Class;
        [Embed(source="../assets/octcat_gloss.png")] private var GLOSSTEXTURE : Class;
		
        //----------------------------------
        //  土台用
        //----------------------------------
        [Embed(source = "../assets/ground/texture.png")] private var GROUNDTEXTURE : Class;
        [Embed(source = "../assets/ground/refrec.png")]private static const GROUNDREFRECTION : Class;
        [Embed(source = "../assets/ground/bump.png")]private static const GROUNDBUMP : Class;
        [Embed(source = "../assets/ground/alpha.png")] private static const GROUNDOPACITY : Class;
        
        // ----------------------------------
        // 環境マップ用
        // ----------------------------------
        [Embed(source = "../assets/bg/top.jpg")]private static const TOP : Class;
        [Embed(source = "../assets/bg/bottom.jpg")]private static const BOTTOM : Class;
        [Embed(source = "../assets/bg/left.jpg")] private static const LEFT : Class;
        [Embed(source = "../assets/bg/right.jpg")]private static const RIGHT : Class;
        [Embed(source = "../assets/bg/front.jpg")]private static const FRONT : Class;
        [Embed(source = "../assets/bg/back.jpg")]private static const BACK : Class;
		
        private var _container : Object3D;
        private var _amblight : AmbientLight;
        private var _oLight : OmniLight;
        private var _dLight : DirectionalLight;
        private var _plane : Plane;
        private var _environmentMap : BitmapCubeTextureResource;
        private var _environmentMaterial : EnvironmentMaterial;
        private var _cameraR : int = 512;

        /**
         * 
         */
        public function OctcatAlternativa3D()
        {
            super({antiAlias:4});
            backgroundColor = 0xffffff;
        }

        override protected function atInit() : void
        {
            // --------------------------------------------------------------------------
            //
            // ライト
            //
            // --------------------------------------------------------------------------

            // ----------------------------------
            // 環境光
            // ----------------------------------
            _amblight = new AmbientLight(0xd8d8d8);
            scene.addChild(_amblight);

            // ----------------------------------
            // ディレクショナルライト
            // ----------------------------------
            _dLight = new DirectionalLight(0xe3e3e3);
            _dLight.rotationX = Math.PI / 2;
            _dLight.rotationY = Math.PI / 2;
            _dLight.rotationZ = Math.PI / 10;
            scene.addChild(_dLight);

            // ----------------------------------
			// オムニライト
            //----------------------------------
			_oLight = new OmniLight(0x64625f, 100, 30000);
			_oLight.x = 250;
			_oLight.y = 100;
			_oLight.z = 900;
			scene.addChild(_oLight);
			
			//--------------------------------------------------------------------------
			//
			// コンテナ
			//
			//--------------------------------------------------------------------------
			_container = scene.addChild(new Object3D())as Object3D;
			_container.scaleX = _container.scaleY = _container.scaleZ = 60;
			
			
			//--------------------------------------------------------------------------
			//
			//  土台
			//
			//--------------------------------------------------------------------------
			
            // ----------------------------------
			// 環境マップ用のリソースを作る
			// ----------------------------------
             _environmentMap = new BitmapCubeTextureResource(
				new LEFT().bitmapData, new RIGHT().bitmapData, 
				new BACK().bitmapData, new FRONT().bitmapData,
				new BOTTOM().bitmapData, new TOP().bitmapData
            );
			
			// ----------------------------------
			// 環境マップマテリアルの作成
			// ----------------------------------
			var diffuseMap : TextureResource = new BitmapTextureResource(new GROUNDTEXTURE().bitmapData);
			var normalMap : TextureResource = new BitmapTextureResource(new GROUNDBUMP().bitmapData);
			var reflectionMap:TextureResource = new BitmapTextureResource(new GROUNDREFRECTION().bitmapData);
			var opacityMap:TextureResource = new BitmapTextureResource(new GROUNDOPACITY().bitmapData);
			_environmentMaterial = new EnvironmentMaterial(
									 diffuseMap
									, _environmentMap
                                    , normalMap
                                    , reflectionMap
									, null//lightMap
									, opacityMap
									, 1
                                    );
			_environmentMaterial.reflection = 0.3;
			_environmentMaterial.alphaThreshold = 1;//## これ大事	
			
			_plane = new Plane(4, 4, 16, 16, true, false, _environmentMaterial, _environmentMaterial);
			_container.addChild(_plane);

            // --------------------------------------------------------------------------
            //
            // モデル
            //
            // --------------------------------------------------------------------------

            // ----------------------------------
			// モデルマテリアル
			// ----------------------------------
			var material : StandardMaterial = new StandardMaterial(
				new BitmapTextureResource(new MAINTEXTURE().bitmapData)
				,new BitmapTextureResource(new BUMPTEXTURE().bitmapData)
				,new BitmapTextureResource(new SPECULARTEXTURE().bitmapData)
				,new BitmapTextureResource(new GLOSSTEXTURE().bitmapData)
			);
			
			// ----------------------------------
			// モデルパース
			// ----------------------------------
			var parser : ParserCollada = new ParserCollada();
			parser.parse(XML(new MAINMODEL()));

            for (var i : int = 0; i < parser.objects.length; i++)
            {
                if (parser.hierarchy.length > i)
                {
                    // メッシュオブジェクトの場合
                    if (parser.hierarchy[i] is Mesh)
                    {
                        var mesh : Mesh = parser.hierarchy[i] as Mesh;
                        // ## StandardMaterialを適用させる場合はTangent情報が必要。
                        mesh.geometry.calculateTangents(0);
                        mesh.setMaterialToAllSurfaces(material);
                        // 画面に表示
                        _container.addChild(mesh);
                        // ----------------------------------
                        // 確認用ワイヤーフレーム
                        // ----------------------------------
                        // var wire : WireFrame = WireFrame.createEdges(mesh, 0x00f0c2, 1 );
                        // _container.addChild(wire);
                    }
                }
            }

            // ----------------------------------
			// infomaton
			// ----------------------------------
			useDiagram = true;
			
			var _tf : TextField = addChild(new TextField()) as TextField;
			_tf.defaultTextFormat = new TextFormat("＿ゴシック", 15, 0x797979);
			_tf.autoSize = TextFieldAutoSize.LEFT;
			_tf.text = "Alternativa3D ver" + Alternativa3D.version + " / " + "Blender2.63a (Collada)";
			_tf.x = _tf.y = 10;
        }


		/**
		 * PreRender
		 */
		override protected function atPreRender() : void
		{
			// ----------------------------------
			// コンテナ回転
			// ----------------------------------
			_container.rotationZ += 0.75 * Math.PI / 180;
			
			// ----------------------------------
			// 視点移動
			// ----------------------------------
			var t : Number = getTimer();
			cameraController.setObjectPosXYZ(
            	  0 
                , 512 
                , 256 + Math.cos(t / 1024) * _cameraR * 0.24
				);
			cameraController.lookAtXYZ(0, 0, 128);
		}
	}
}
