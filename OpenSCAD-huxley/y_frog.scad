include <parameters.scad>;
use <library.scad>;

xbars=109;
ylength=50; // 86;
d=22;
w=5;

belt_clamp_x=33;
belt_to_switch=26;
x_join=xbars/2;
join_thick=16;

// Triangle values

yl2 = ylength/2;
a = (yl2*yl2 + xbars*xbars)/(2*xbars);
b = xbars - a;
theta = atan(xbars/yl2);

p0=[0,yl2,0];
p1=[0,-yl2,0];
p2=[xbars,0,0];

p00=p0+[12,-12,0];
p11=p1+[12,12,0];
p22=p2+[-20,0,0] ;

module accesories(holes=false)
{
	// Bearings

	translate(p0)
		rotate([-90,180,180])
			adjustable_bearing(true,holes);

	translate(p1)
		rotate([-90,180,180])
			adjustable_bearing(true,holes);
	
	translate(p2)
		rotate([-90,180,0])
			adjustable_bearing(false,holes);


	if(!holes)
	{
		// Clearance

		//mirror([0,0,1])
			//cube([10,10,20]);

		// Limit switch

		translate([belt_clamp_x+belt_to_switch,-yl2-30,6])
			cube([2,20,2],center=true);

		// Y belt

		translate([belt_clamp_x-3,-100,-5.7-1.5])
			cube([6,200,1.5]);
		translate([belt_clamp_x-3,-100,-5.7-1.5+8.75])
			cube([6,200,1.5]);

		// Y rods

		rotate([90,0,0])
			rod(1.5*ylength,false);
		
		translate([xbars,0,0])
			rotate([90,0,0])
				rod(1.5*ylength,false);
	}
}

module belt_clamp_holes(depth=2)
{
	for(i=[-1,1])
		translate([i*5,0,0])
		{
			cylinder(r=screwsize/2, h=50, center=true, $fn=10);
			if(depth > 4)
				translate([0,0,6])
					cylinder (h = 10, r = nutdiameter / 1.8, center = true, $fn = 6);
		}
}

module belt_clamp(depth=6, nut=false, holes=false)
{
	if(holes)
		belt_clamp_holes();
	else
		difference()
		{
			cube([20,8,depth], center=true);
			belt_clamp_holes(depth);
		}
}

module pusher_holes()
{
	translate([0, 14, 0])
		rotate([0,0,90-theta])
		{
			for(j=[-1,1])
				translate([j*15, 0, 0])
					cylinder(r=screwsize/2, h=50, center=true, $fn=10);
		}
}

module limit_pusher(offset=[x_join+8, -x_join/tan(theta)-15, 0], holes=false)
{

		if(holes)
			translate(offset)
				pusher_holes();
		 else
		{
			union()
			{
				translate(offset)
					difference()
					{
						difference()
						{
							translate([5, -6, 0])
								rotate([0,0,90-theta])
									cube([36, 50, 5], center=true);
								pusher_holes();
						}
	
						translate(-offset-[0,0,10])
							big_chop();
					}
				
					translate([belt_clamp_x+belt_to_switch-5,offset.y-8,offset.z-2.5])
						difference()
						{
							cube([10,15,20]);
							translate([-2,13,-2])
								rotate([20,0,0])
									cube([20,15,30]);
						}
			}
		}
}

module big_chop()
{
	union()
	{
		translate(p0+[0, 20,-25])
			rotate([0,0,-90+theta])
				cube([xbars+26+50, ylength+20+50, 5+50]);
				
		mirror([0,1,0])
			translate(p0+[0, 20,-25])
				rotate([0,0,-90+theta])
					cube([xbars+26+50, ylength+20+50, 5+50]);			
	
		linear_extrude(height = 100, center = true, convexity = 10, twist = 0)
			polygon(points=[[p00.x,p00.y],[p11.x,p11.y],[p22.x,p22.y]]);



		for(i=[-1,1])
		{
			translate([x_join + 45, i*(x_join/tan(theta)+2),-2.75])
				rotate([0,-90,0])
					teardrop(r=screwsize/2, h = 50, truncateMM=0.5);

			translate([x_join + 45, i*(x_join/tan(theta)+12),-2.75])
				rotate([0,-90,0])
					teardrop(r=screwsize/2, h = 50, truncateMM=0.5);
		}

		translate([-6, 25,-2.75])
			rotate([0,-90,90])
				teardrop(r=screwsize/2, h = 50, truncateMM=0.5);

		translate([3, 25,-2.75])
			rotate([0,-90,90])
				teardrop(r=screwsize/2, h = 50, truncateMM=0.5);

		for(i=[-1,1])
			translate([belt_clamp_x+2.5,i*(yl2+11),0])
					cube([35,20,60], center=true);
	}
}

module y_frog()
{
	translate([0, 0,-14])
	{		
		difference()
		{
			union()
			{
				translate([-13, -yl2-10,0])
					cube([xbars+26, ylength+20, 5]);
				strut(p00, p11, 10,10,2);
				strut(p00, p22, 10,10,2);
				strut(p11, p22, 10,10,2);
				translate([x_join, -(ylength +50)/2,-5])
					cube([join_thick, ylength+50, 10]);
				translate([-9, -join_thick/2,-5])
					cube([30, join_thick, 10]);
			}

			big_chop();

			accesories(holes=true);

			for(i=[-1,1])
				translate([belt_clamp_x,i*(yl2-4),0])
					belt_clamp(depth=2, holes=true);

			limit_pusher(holes=true);
		}
	}
}



/*
difference()
{
	y_frog();
	translate([-100, 0,-100]) cube([500, 500, 500]);
	translate([x_join + join_thick/2, -250,-100]) cube([500, 500, 500]);
}

difference()
{
	y_frog();
	mirror([0,1,0])
		translate([-100, 0,-100]) cube([500, 500, 500]);
	translate([x_join + join_thick/2, -250,-100]) cube([500, 500, 500]);
}

intersection()
{
	y_frog();
	translate([x_join + join_thick/2, -250,-100]) cube([500, 500, 500]);
}
*/
y_frog();

translate([0,0,-7])
	limit_pusher(holes=false);

translate([belt_clamp_x,-yl2+4,-2.7])
{
	belt_clamp(depth=6, nut=true, holes=false);
	translate([0,0,-5.5])
		belt_clamp(depth=2, nut = false, holes=false);
}

accesories(false);