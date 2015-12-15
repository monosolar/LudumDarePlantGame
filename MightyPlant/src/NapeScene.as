package {

	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.StageQuality;
    import flash.display.Sprite;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.events.Event;
import flash.events.TimerEvent;
import flash.geom.Point;
	import flash.system.System;
    import flash.text.TextField;
    import flash.text.TextFormat;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
import flash.utils.setInterval;

import nape.constraint.PivotJoint;
import nape.geom.Vec2List;

import nape.shape.Circle;
import nape.shape.Shape;

import nape.space.Space;
    import nape.space.Broadphase;
    import nape.phys.Body;
    import nape.phys.BodyType;
    import nape.shape.Polygon;
    import nape.geom.Vec2;
    import nape.util.Debug;
    import nape.util.BitmapDebug;

    public class NapeScene extends Sprite {

		[Embed(source="../assets/buildMap.xml", mimeType="application/octet-stream")]
		public static const BUILD_MAP_CLASS:Class;

		public var globalScrollPositionChange:Function;

		private var space:Space;
		private var debug:Debug;

		private var plantsBendsBodiesVect:Vector.<Body> = new Vector.<Body>();

		private var graphicContainer:Sprite = new Sprite();;

        private var plantGraphicContainer:Sprite = new Sprite();;

		public function NapeScene():void {

			initialiseNape(null);

			this.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			this.addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}

        public function leftControlHandler():void
        {
           getHeadBend().rotation += 0.1;
        }

        public function rightControlHandler():void
        {
            getHeadBend().rotation -= 0.1;
        }

		private function initialiseNape(ev:Event):void {

			var gravity:Vec2 = Vec2.weak(0, -600);
			space = new Space(gravity);
			debug = new BitmapDebug(1000, 3000, 0x000000,true);
			addChild(debug.display);
			this.addChild(graphicContainer);
            this.addChild(plantGraphicContainer);

			setUp();
		}

        private function startGrowing():void
        {
            createObject(Vec2.get(505.35, 30));
            setInterval(growHeadIteration, 100);
        }

		private function setUp():void {

			var floor:Body = new Body(BodyType.STATIC);
			floor.shapes.add(new Polygon(Polygon.rect(0, 0, 1000, 1)));
			floor.space = space;

		/*	var ball:Body = new Body(BodyType.DYNAMIC);
			ball.shapes.add(new Circle(50));
			ball.position.setxy(506, 145);
			ball.angularVel = 10;
			ball.space = space;*/

            var box:Body;

			var buildMapnXML = XML(new BUILD_MAP_CLASS());

			var bricksBGXML:XMLList= buildMapnXML.brickPatterns.BrickPatternBG;

			var stonesBGXML:XMLList= buildMapnXML.stonePatterns.StonePatternBG;

			var wallsXML:XMLList= buildMapnXML.walls.Wall;

			var floorPanelsXML:XMLList = buildMapnXML.floors.FloorPanel;

			var woodBoxessXML:XMLList = buildMapnXML.woodBoxes.WoodBox;

			for each (var brickBG:XML in bricksBGXML) {

				addStaticGraphicByParams({x:brickBG.@x, y:brickBG.@y}, BrickPatternBGSprite);
			}

			for each (var stoneBG:XML in stonesBGXML) {

				addStaticGraphicByParams({x:stoneBG.@x, y:stoneBG.@y}, StonePatternBGSprite);
			}

			for each (var wall:XML in wallsXML) {
				box = new Body(BodyType.STATIC);
				box.shapes.add(new Polygon(Polygon.box(wall.@width, wall.@height)));
				box.position.setxy(wall.@x, wall.@y);
				box.space = space;
				addStaticGraphicByBody(box, Wall);
			}

			for each (var floorPanel:XML in floorPanelsXML) {
				box = new Body(BodyType.STATIC);
				box.shapes.add(new Polygon(Polygon.box(floorPanel.@width, floorPanel.@height)));
				box.position.setxy(floorPanel.@x, floorPanel.@y);
				box.space = space;
				addStaticGraphicByBody(box, FloorPanel);
			}


            var plantGround:Body = new Body(BodyType.STATIC);
            plantGround.shapes.add(new Polygon(Polygon.box(40, 30)));
            plantGround.position.setxy(505.35, 21);
            plantGround.space = space;
            addStaticGraphicByBody(plantGround, Wall);

            plantsBendsBodiesVect.push(plantGround);

		}

		////////////////////// PLANT ///////////////////////////

		private function createObject(currentPos:Vec2):void {

            attachBend(getPrevPos(), currentPos);

			if (plantsBendsBodiesVect.length > 1)
			{
				var bodyToJoin1:Body = plantsBendsBodiesVect[plantsBendsBodiesVect.length-1];
				var bodyToJoin2:Body = plantsBendsBodiesVect[plantsBendsBodiesVect.length-2];
				//joinBodies(bodyToJoin1, bodyToJoin2);
			}
		}

		private function attachBend(pos1:Vec2, pos2:Vec2):void
		{
			var body:Body = new Body(BodyType.KINEMATIC, pos1);

			const initUpHeight:Number = 3;
			const initDownHeight:Number = 10;

			var distance:Number = Vec2.distance(pos1, pos2);
            body.userData.distance = distance;

			var polygon:Polygon = new Polygon(
					[
						Vec2.get(0,-initDownHeight/2),
						Vec2.get(0,initDownHeight/2),
						Vec2.get(distance,initUpHeight/2),
						Vec2.get(distance,-initUpHeight/2)
					]
			);

            var viewportShape:Shape = polygon;

            viewportShape.filter.collisionGroup = 2;
            viewportShape.filter.collisionMask  = ~2;
            viewportShape.body = body;

            body.rotation = getRadOfTwoPos(pos1,pos2);

			body.userData.sprite = new Sprite();
            plantGraphicContainer.addChild(body.userData.sprite);

			body.space = space;

            plantsBendsBodiesVect.push(body);
		}

		private function joinBodies(body1:Body, body2:Body):void
		{
            var pivotPoint:Vec2 = body1.localPointToWorld(Vec2.get(0,0));

            var pivotJoint:PivotJoint = new PivotJoint(
                    body1, body2,
                    body1.worldPointToLocal(pivotPoint, true),
                    body2.worldPointToLocal(pivotPoint, true)
            )

            pivotJoint.stiff = true;
            pivotJoint.frequency =  20.0;
            pivotJoint.damping = 60;
            pivotJoint.space = space;

            pivotPoint.dispose();
		}

		private function growBendsIteration():void
		{
			for each (var bend:Body in plantsBendsBodiesVect)
			{
                //if (plantsBendsBodiesVect.indexOf(bend) == 0) break;

                bend.space = null;

                var bendPolygon:Polygon = bend.shapes.at(0) as Polygon;

                if (bendPolygon.localVerts.at(1).y < 15 ) {
                    bendPolygon.localVerts.at(0).y *= 1.2;
                    bendPolygon.localVerts.at(1).y *= 1.2;
                }

                if (bendPolygon.localVerts.at(2).y < 15)
                {
                    bendPolygon.localVerts.at(2).y *= 1.2;
                    bendPolygon.localVerts.at(3).y *= 1.2;
                }

                bend.space = space;

                refreshBendGraphic(bend);

			}
		}

        private function growHeadIteration():void
        {
            if (plantsBendsBodiesVect.length < 2) return;

            var headBend:Body = getHeadBend();

            headBend.space = null;

            var bendPolygon:Polygon = headBend.shapes.at(0) as Polygon;

            bendPolygon.localVerts.at(2).x += 5;
            bendPolygon.localVerts.at(3).x += 5;

            headBend.space = space;

            refreshBendGraphic(headBend);

            var headLength:Number = (headBend.shapes.at(0) as Polygon).localVerts.at(3).x;

            globalScrollPosition(headBend.
                    localPointToWorld(Vec2.get(headLength,0)));

            if (headLength > 40)
                createObject(headBend.localPointToWorld(Vec2.get(headLength+10,0)));
        }

        private function growingTimerIteration():void
        {
            growHeadIteration();
            growBendsIteration();
        }



		private function globalScrollPosition(pos:Vec2):void
		{
			globalScrollPositionChange(new Point(pos.x, pos.y));
		}

		private function addStaticGraphicByBody(body:Body, grapcicClass:Class):void
		{
			var displayObject:DisplayObject = new grapcicClass();
			displayObject.x = body.position.x;
			displayObject.y = body.position.y;
			displayObject.rotation = body.rotation * 180 / Math.PI;

			graphicContainer.addChild(displayObject);
		}

		private function addStaticGraphicByParams(params:Object, grapcicClass:Class):void
		{
			var displayObject:DisplayObject = new grapcicClass();
			displayObject.x = params.x;
			displayObject.y = params.y;

			graphicContainer.addChild(displayObject);
		}

        private function refreshBendGraphic(body:Body):void
        {
            if (!body.userData.sprite) return;

            var sprite:Sprite = body.userData.sprite;
            sprite.x = body.position.x;
            sprite.y = body.position.y;
            sprite.rotation = body.rotation*57.2957795;

            var vec2List:Vec2List = (body.shapes.at(0) as Polygon).localVerts

            sprite.graphics.clear();
            sprite.graphics.beginFill(0x006600);


            sprite.graphics.moveTo(vec2List.at(0).x,vec2List.at(0).y);

            for (var  i:uint = 1; i < vec2List.length; i++)
            {
                sprite.graphics.lineTo(vec2List.at(i).x,vec2List.at(i).y);
            }

            sprite.graphics.lineTo(vec2List.at(0).x,vec2List.at(0).y);

            sprite.graphics.endFill();
        }

        private function getPrevPos():Vec2
        {
            if (plantsBendsBodiesVect.length > 1)
            {
                var lastBend:Body = plantsBendsBodiesVect[plantsBendsBodiesVect.length-1];
                return lastBend.localPointToWorld(
                        Vec2.get((lastBend.shapes.at(0) as Polygon).localVerts.at(3).x,0)
                );
            }
            else
            {
                return Vec2.get(505,29);
            }

        }

        private function getHeadBend():Body
        {
            if (plantsBendsBodiesVect.length > 1)
                return plantsBendsBodiesVect[plantsBendsBodiesVect.length-1]
            else
              return null;
        }

        private function getRadOfTwoPos(pos1:Vec2, pos2:Vec2):Number
		{
			var deltaX = pos2.x - pos1.x;
			var deltaY = pos2.y - pos1.y;
			var rad = Math.atan2(deltaY, deltaX);

			return rad;

		}

		private function degToRad(deg:Number):Number
		{
			return (Math.PI * deg ) / 180;
		}

		private function mouseDown(ev:MouseEvent):void {
			var mp:Vec2 = Vec2.get(mouseX, mouseY);
			startGrowing();
		}

		private function enterFrameHandler(ev:Event):void {
			space.step(1 / 60);

			/*debug.clear();
			debug.draw(space);
			debug.flush();*/
		}
    }
}