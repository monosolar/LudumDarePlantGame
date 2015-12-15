/**
 * Created by yauheni-kasenko on 12/12/2015.
 */
package
{
	import flash.display.Sprite;
	import flash.utils.Dictionary;

	import nape.constraint.PivotJoint;

	import nape.geom.GeomPoly;
	import nape.geom.GeomPolyList;
	import nape.geom.Mat23;
	import nape.geom.Vec2;
	import nape.geom.Vec2List;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.shape.Circle;
	import nape.shape.Polygon;

	[SWF(frameRate="60", width="800", height="600", backgroundColor="0x000000")]

	public class PlantGrowing extends Template
	{

		private var vectorOfMouseVec2:Vector.<Vec2> = new Vector.<Vec2>();

		private var plantsBendsPolygonsDict:Dictionary = new Dictionary();

		public function PlantGrowing()
		{
			super({
					  gravity: Vec2.get(0, 600),
					  generator: createObject
				  });
		}

		override protected function init():void
		{
			vectorOfMouseVec2.push(Vec2.get(380,545));

			createBorder();

			var frequency:Number = 20.0;
			var damping:Number = 1.0;

			//var pivotPoint:Vec2 = Vec2.get(x(cellWidth/2),y(cellHeight/2));



			/*c.stiff = false;
			c.frequency = frequency;
			c.damping = damping;
			c.space = space;*/

		}

		private function createObject(currentPos:Vec2):void {

			var prevPos:Vec2 = (vectorOfMouseVec2[vectorOfMouseVec2.length-1]);
			vectorOfMouseVec2.push(currentPos.copy());


			//growBendsIteration();
			attachBend(prevPos, currentPos);


		}

		private function attachBend(pos1:Vec2, pos2:Vec2):void
		{
			var body:Body = new Body(BodyType.KINEMATIC, pos1);

			const initUpWidt:Number = 30;
			const initDownWidt:Number = 30;

			var distance:Number = Vec2.distance(pos1, pos2);

			var polygon:Polygon = new Polygon(
					[
						Vec2.get(-initDownWidt/2,0,true),
						Vec2.get(initDownWidt/2,0,true),
						Vec2.get(initUpWidt/2,-distance,true),
						Vec2.get(-initUpWidt/2,-distance,true)

						/*Vec2.weak(-initDownWidt/2,0),
						Vec2.weak(initDownWidt/2,0),
						Vec2.weak(initUpWidt/2,-distance),
						Vec2.weak(-initUpWidt,-distance)*/
					]
			);

			plantsBendsPolygonsDict[polygon] = polygon;

			polygon.rotate(getRadOfTwoPos(pos1,pos2));

			body.shapes.add(polygon);


			var t:Sprite = new Sprite();
			t.graphics.beginFill(0x98EDCF5);
			t.graphics.lineTo(10,20);
			t.graphics.lineTo(20,30);
			t.graphics.lineTo(10,30);
			t.graphics.lineTo(30,10);
			t.graphics.lineTo(0,0);
			t.graphics.endFill();

			body.userData.sprite=t;
			addChild(body.userData.sprite);

			body.space = space;



		}

		private function growBendsIteration():void
		{
			for each (var bendPolygon:Polygon in plantsBendsPolygonsDict)
			{
				//bendPolygon.transform(new Mat23(1.3,0,0,1,0,0));

				/*bendPolygon.localVerts.at(0).x -= 5;
				bendPolygon.localVerts.at(1).x += 5;
				bendPolygon.localVerts.at(2).x -= 3;
				bendPolygon.localVerts.at(3).x += 3;*/
			}
		}

		private function getRadOfTwoPos(pos1:Vec2, pos2:Vec2):Number
		{
			var deltaX = pos2.x - pos1.x;
			var deltaY = pos2.y - pos1.y;
			var rad = Math.atan2(deltaY, deltaX);

			return rad + degToRad(90);
		}

		private function degToRad(deg:Number):Number
		{
			return (Math.PI * deg ) / 180;
		}
	}
}
