void staticHexagonActions()
{
    // Enum determines action to perform
    
    //none, return to skip
    if (staticAction == StaticAction.none)
    {
        //reset actionTime
        actionTime = 0.0f;
        
        allowFlowInfluence = true;
        
        return;
    }
    //twirl, spin columns of shapes
    else if (staticAction == StaticAction.twirl)
    {
        allowFlowInfluence = true;
        
        float x = currentTime;

        for (Hexagon hex : hexes)
        {            
            hex.velocity.add(new PVector(sin(x), cos(x)));
            
            hex.mReturnsToOrigin = true;
            hex.mSnapToOrigin = false;
    
            //updating hexagon
            //hex.updateHex();
            
            x += delta;
        }
        
        //if flow max crossed, then stop action
        if (xFlow > flowThreshold && yFlow > flowThreshold)
        {
            for (Hexagon hex : hexes)
            {
                hex.mReturnsToOrigin = true;
                hex.mSnapToOrigin = true;
            }
            
            staticAction = StaticAction.none;
        }
    }
    else if (staticAction == StaticAction.swirl)
    {
        allowFlowInfluence = true;
        
        float x = currentTime;

        for (Hexagon hex : hexes)
        {            
            hex.velocity.add(new PVector(sin(x), cos(x)));
            
            hex.mReturnsToOrigin = false;
            hex.mSnapToOrigin = false;
    
            //updating hexagon
            //hex.updateHex();
            
            x += delta;
        }
        
        //if flow max crossed, then stop action
        if (xFlow > flowThreshold && yFlow > flowThreshold)
        {
            for (Hexagon hex : hexes)
            {
                hex.mReturnsToOrigin = true;
                hex.mSnapToOrigin = true;
            }
            
            staticAction = StaticAction.none;
        }
    }
    //explode, shapes explodes then returns
    else if (staticAction == StaticAction.explode)
    {
        float x = currentTime;
        float maxTime = 4.5;
        float multiplier = 1.0/32.0;
        
        allowFlowInfluence = false;

        boolean isDone = false;
        
        //if reached max time, then set bool to reset hexes
        if (actionTime >= maxTime)
        {
            isDone = true;
            actionTime = 0.0;
            staticAction = StaticAction.none;
        }
        
        for (Hexagon hex : hexes)
        {
            //no return or decay
            hex.mReturnsToOrigin = false;
            hex.mDecayVelocity = false;
            
            hex.velocity.add(new PVector(sin(x), cos(x)).mult(1 / (1 + abs(hex.velocity.x)/4 + abs(hex.velocity.y)/4)));
    
            //updating hexagon
            //hex.updateHex();
            
            x += delta;
            
            //if done, then reset bools
            if (isDone)
            {
                hex.mReturnsToOrigin = true;
                hex.mDecayVelocity = true;
                
                //reset time
                actionTime = 0.0f;
                staticTime = 0.0f;
                
                allowFlowInfluence = true;
                
                //giving static time some extra time
                staticTime = -2.0;
            }
        }

    }
    //moves fluidly
    else if (staticAction == StaticAction.blanket)
    {
        float x = currentTime;
        float maxTime = 12.0;
        float multiplier = 1.0/4.0;
        
        allowFlowInfluence = false;

        boolean isDone = false;
        
        //if reached max time, then set bool to reset hexes
        if (actionTime >= maxTime)
        {
            isDone = true;
            actionTime = 0.0;
            staticAction = StaticAction.none;
        }
        
        for (Hexagon hex : hexes)
        {
            //no return or decay
            hex.mReturnsToOrigin = true;
            hex.mDecayVelocity = false;
            hex.mSnapToOrigin = false;
            
            hex.velocity.add(new PVector(sin(x*3), cos(x*3)).mult(1 / (1 + abs(hex.velocity.x) + abs(hex.velocity.y))));
    
            //updating hexagon
            //hex.updateHex();
            
            x += delta;
            
            //if done, then reset bools
            if (isDone)
            {
                hex.mReturnsToOrigin = true;
                hex.mDecayVelocity = true;
                hex.mSnapToOrigin = true;
                
                //reset time
                actionTime = 0.0f;
                staticTime = 0.0f;
                
                allowFlowInfluence = true;
            }
        }

    }
    //also moves fluidly
    else if (staticAction == StaticAction.wavy)
    {
        float x = currentTime;
        float maxTime = 12.0;
        float multiplier = 1.0/4.0;
        
        allowFlowInfluence = false;

        boolean isDone = false;
        
        //if reached max time, then set bool to reset hexes
        if (actionTime >= maxTime)
        {
            isDone = true;
            actionTime = 0.0;
            staticAction = StaticAction.none;
        }
        
        for (Hexagon hex : hexes)
        {
            //no return or decay
            hex.mReturnsToOrigin = true;
            hex.mDecayVelocity = false;
            hex.mSnapToOrigin = false;
            
            hex.velocity.add(new PVector(sin(x*3), cos(x*3)).mult(multiplier));
    
            //updating hexagon
            //hex.updateHex();
            
            x += delta;
            
            //if done, then reset bools
            if (isDone)
            {
                hex.mReturnsToOrigin = true;
                hex.mDecayVelocity = true;
                hex.mSnapToOrigin = true;
                
                //reset time
                actionTime = 0.0f;
                staticTime = 0.0f;
                
                allowFlowInfluence = true;
            }
        }

    }

    
    //add to action timer
    actionTime += delta;
    
}
