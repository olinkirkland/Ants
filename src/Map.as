package {
import flash.geom.Point;
import flash.geom.Rectangle;

import global.Rand;

import graph.QuadTree;

public class Map {
    public const BOUNDS:Rectangle = new Rectangle(0,0,500,360);

    public var nodes:Vector.<Node>;

    private var points:Vector.<Point>;
    private var quadTree:QuadTree;

    public function Map() {
        // Generate a new map
        makePoints(20);
        makeNodesFromPoints();
    }

    private function makeNodesFromPoints():void {
        nodes = new Vector.<Node>();
        for each (var p:Point in points) {
            var node:Node = new Node();
            node.point = p;
            nodes.push(node);
        }
    }

    public function makePoints(spacing:int):void
    {
        points = new Vector.<Point>();
        quadTree = new QuadTree(BOUNDS);

        // Make border points
        var borderPointsCount:int = 0;
        var gap:int = 5;
        for (var i:int = gap; i < BOUNDS.width; i += 2 * gap)
        {
            addPoint(new Point(i, gap));
            addPoint(new Point(i, BOUNDS.height - gap));
            borderPointsCount+=2;
        }

        for (i = 2 * gap; i < BOUNDS.height - gap; i += 2 * gap)
        {
            addPoint(new Point(gap, i));
            addPoint(new Point(BOUNDS.width - gap, i));
            borderPointsCount+=2;
        }

        // Fill the rest of the area
        makePointsInArea(BOUNDS, spacing, 5);

        // Remove border points
        while (borderPointsCount > 0)
        {
            var p:Point = points.shift();
            borderPointsCount--;
        }
    }


    private function makePointsInArea(area:Rectangle, spacing:int, precision:int):void
    {
        // The active point queue
        var queue:Vector.<Point> = new Vector.<Point>();

        var point:Point = new Point(int(area.width / 2),
                int(area.height / 2));

        var doubleSpacing:Number = spacing * 2;
        var doublePI:Number = 2 * Math.PI;

        var box:Rectangle = new Rectangle(0,
                0,
                2 * spacing,
                2 * spacing);

        addPoint(point);
        queue.push(point);

        var candidate:Point = null;
        var angle:Number;
        var distance:int;

        while (queue.length > 0)
        {
            point = queue[0];

            for (var i:int = 0; i < precision; i++)
            {
                angle = Rand.rand.next() * doublePI;
                distance = Rand.rand.between(spacing, doubleSpacing);

                candidate = new Point(point.x + distance * Math.cos(angle),
                        point.y + distance * Math.sin(angle));

                // Check point distance to nearby points
                box.x = candidate.x - spacing;
                box.y = candidate.y - spacing;
                if (quadTree.isRangePopulated(box))
                {
                    candidate = null;
                }
                else
                {
                    // Valid candidate
                    if (!area.contains(candidate.x, candidate.y))
                    {
                        // Candidate is outside the area, so don't include it
                        candidate = null;
                        continue;
                    }
                    break;
                }
            }

            if (candidate)
            {
                addPoint(candidate);
                queue.push(candidate);
            }
            else
            {
                // Remove the first point in queue
                queue.shift();
            }
        }
    }


    private function addPoint(p:Point):void
    {
        points.push(p);
        quadTree.insert(p);
    }
}
}
