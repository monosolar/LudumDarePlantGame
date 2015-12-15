package {


import nape.constraint.PivotJoint;
import nape.constraint.WeldJoint;
import nape.geom.AABB;
import nape.geom.Vec2;
import nape.geom.Vec2;
    import nape.phys.Body;
    import nape.phys.BodyType;
    import nape.shape.Circle;
    import nape.shape.Polygon;

    import Template;

    import flash.display.BitmapData;
    import flash.display.BitmapDataChannel;
    import flash.display.BlendMode;
    import flash.display.Sprite;
    import flash.geom.Matrix;

import nape.shape.Shape;

[SWF(frameRate="60", width="1000", height="600", backgroundColor="0x000000")]

    public class PivotJointTest extends Template {
        public function PivotJointTest():void {
            super({
                gravity: Vec2.get(0, 600)
            });
        }

        override protected function init():void {
            var w:uint = stage.stageWidth;
            var h:uint = stage.stageHeight;

            createBorder();

            var body:Body = new Body(BodyType.DYNAMIC, Vec2.get(300,300));
            var viewportShape:Shape = new Polygon(Polygon.rect(0,0,100, 30));

            viewportShape.filter.collisionGroup = 2;
            viewportShape.filter.collisionMask  = ~2;

            viewportShape.body = body;
            body.space = space;

            var body2:Body = new Body(BodyType.DYNAMIC, Vec2.get(400,300));
            var viewportShape:Shape = new Polygon(Polygon.rect(0,0,100, 30));

            viewportShape.filter.collisionGroup = 2;
            viewportShape.filter.collisionMask  = ~2;

            viewportShape.body = body2;
            body2.space = space;

            var pivotPoint:Vec2 = body2.localPointToWorld(Vec2.get(0,15));
            var pivotJoint:PivotJoint = new PivotJoint(
                    body, body2,
                    body.worldPointToLocal(pivotPoint, true),
                    body2.worldPointToLocal(pivotPoint, true)
            )

            pivotJoint.stiff = true;
            /*pivotJoint.frequency =  0.1;
            pivotJoint.damping = 0.1;*/
            pivotJoint.space = space;
            pivotJoint.maxForce = 1000;

            pivotPoint.dispose();

        }


    }
}
