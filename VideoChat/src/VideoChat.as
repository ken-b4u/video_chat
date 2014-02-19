package {
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageQuality;
    import flash.display.StageScaleMode;
    import flash.events.NetStatusEvent;
    import flash.media.Camera;
    import flash.media.Microphone;
    import flash.media.Video;
    import flash.net.NetConnection;
    import flash.net.NetStream;
    import flash.net.ObjectEncoding;
    import flash.media.MicrophoneEnhancedOptions;
	import flash.media.MicrophoneEnhancedMode;

    public class VideoChat extends Sprite {
        private var camera:Camera;
		private var mic:Microphone = Microphone.getEnhancedMicrophone();
		
        private var video:Video;
        private var nc:NetConnection;
        private var ns:NetStream;
		

        public function VideoChat() {	//■ ----- コンストラクタ -----
            init();
        }

        private function init():void {	//■ ----- 初期化メソッド -----
			stage.quality=StageQuality.HIGH;  //画質を高に.
            stage.scaleMode = StageScaleMode.NO_SCALE;	//Flash Player のウィンドウのサイズが変更された場合でもサイズが維持されるように指定.
            stage.align = StageAlign.TOP_LEFT;	//配置を指定.ステージを左上の隅に揃えるよう指定.
            camera = Camera.getCamera();	//ビデオをキャプチャする Camera オブジェクトへの参照を返す
			camera.setMode(320,160,15);	//カメラの縦,横,FPSの指定
			var mic_enhanced_options:MicrophoneEnhancedOptions = mic.enhancedOptions;
			mic_enhanced_options.mode = MicrophoneEnhancedMode.FULL_DUPLEX;
			mic.enhancedOptions = mic_enhanced_options;
			
            if(camera != null){	//カメラ繋いでたら setupCamera()メソッドを呼ぶ
                setupCamera();
            }else{	//繋いでなかったらエラー出力
                trace("カメラがありません。カメラを取りつけ、再度試してください。");
                return;
            }
            nc = new NetConnection();	//NetConnection オブジェクトを作成.
            nc.objectEncoding = ObjectEncoding.AMF3;	//オブジェクトが ActionScript 1.0 および 2.0 の Action Message Format 形式を使用して直列化されることを指定
            nc.addEventListener(NetStatusEvent.NET_STATUS,onNetStatus);		//イベント登録
            nc.connect("rtmp://192.168.36.190/oflaDemo"); // サーバとの接続.引数はストリーミングサーバのアドレス.　★自分の環境に合わせてください
        }

        private function sendVideo():void {	 //■ 接続が成功した場合に呼ばれるメソッド
            ns = new NetStream(nc);		//メディアファイルを再生するときに使用できるストリームを作成し、NetConnection オブジェクトにデータを送信.
            ns.attachCamera(camera);	//カメラ キャプチャ開始
			ns.attachAudio(mic);
            ns.publish("demo2");	//"チャンネル名" にストリームを介してサーバにデータを送信.　★自分の環境に合わせてください
        }

        private function setupCamera():void {	//■ カメラの初期化とビデオストリームを指定、画面に表示など
            video = new Video(camera.width,camera.height);	//初期化
            video.attachCamera(camera);	//表示するカメラからのビデオストリームを指定.ビデオオブジェクトとカメラオブジェクトを関連付ける.
            addChild(video);	//画面に表示する.引数にインスタンスを表示リストに登録する.
        }

        private function onNetStatus(evt:NetStatusEvent):void {	//■ イベントに関するメソッド.
            switch(evt.info.code){	//各イベントに対してswichで管理
                case "NetConnection.Connect.Success":
                    trace("接続成功");
                    sendVideo();
                    break;
                case "NetConnection.Connect.Closed":
                    trace("接続解除");
                    break;
                case "NetConnection.Connect.Faild":
                    trace("接続失敗");
                    break;
                case "NetConnection.Connect.Rejected":
                    trace("接続拒否");
                    break;
                default:
                    trace("evt.info.code");
            }
        }
    }
}