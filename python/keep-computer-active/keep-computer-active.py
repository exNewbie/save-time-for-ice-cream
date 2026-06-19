import Quartz.CoreGraphics as CG, time

def move_mouse():
    loc = CG.CGEventGetLocation(CG.CGEventCreate(None))
    CG.CGEventPost(CG.kCGHIDEventTap,
       CG.CGEventCreateMouseEvent(None, CG.kCGEventMouseMoved, (loc.x + 1, loc.y), 0))
    CG.CGEventPost(CG.kCGHIDEventTap,
       CG.CGEventCreateMouseEvent(None, CG.kCGEventMouseMoved, (loc.x - 1, loc.y), 0))

move_mouse()

