package {

	import flash.display.Sprite;
	import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.geom.Point;
	import flash.text.TextField;

	import nape.geom.Vec2;

	[SWF(frameRate="60", width="1000", height="800", backgroundColor="0x000000")]

	public class Main extends Sprite {

		private var napeScene:NapeScene;

		public function Main() {

			if (stage != null) {
				init(null);
			}
			else {
				addEventListener(Event.ADDED_TO_STAGE, init);
			}
		}

		private function init(e:Event):void
		{
			if (e != null) {
				removeEventListener(Event.ADDED_TO_STAGE, init);
			}

			napeScene = new NapeScene();
//			napeScene.scaleX *= -1;
			napeScene.scaleY *= -1;
			napeScene.y = stage.stageHeight;

			napeScene.x += 50;
			napeScene.y -= 50;
			napeScene.globalScrollPositionChange = scrollinNapeScene;

			var fullBG:GradientBGSprite = new GradientBGSprite();
			addChild(fullBG);

			var mountinBG:MountinParalaxBGSprite = new MountinParalaxBGSprite();
			mountinBG.y = 1000;
			addChild(mountinBG);

			var forestBG:ForestParalaxBGSprite = new ForestParalaxBGSprite();
			forestBG.y = 1000;
			addChild(forestBG);

			addChild(napeScene);

            stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
		}

		private function scrollinNapeScene(pos:Point):void
		{
			trace("►",pos.x,pos.y);

            if (pos.y > 600)
            {
                napeScene.y = (pos.y - 600) + stage.stageHeight + 200;
            }
		}

        private function keyDown(ev:KeyboardEvent):void {

            // LEFT
            if (ev.keyCode == 37 || ev.keyCode == 65) {
                napeScene.leftControlHandler();
            }

            // RIGHT
            if (ev.keyCode == 39 || ev.keyCode == 68) {
                napeScene.rightControlHandler();
            }
        }

	}
}
