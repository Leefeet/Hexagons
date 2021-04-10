class Hexagon
{
    float originX = 0;
    float originY = 0;
    float currentX = 0;
    float currentY = 0;
    int mWidth = 0;
    int mHue = 0;
    PVector velocity = new PVector(0, 0);
    float returnSpeed = 0.01;
    float speedDecay = 0.75;
    int closeDistance = 2; //pixels
    int minFlowMag = 50; //magnitude

    //timer for returning back to original hue
    int mOrgHue = 0;
    float mTimeReturn = 3.0; //seconds
    float mTimePassed = 0.0;

    //shape
    int mVertices = 6;

    //bool for movement
    boolean mIsMoving;

    //bool to return to origin
    boolean mReturnsToOrigin = true;
    
    //other bools
    boolean mDecayVelocity = true;
    boolean mSnapToOrigin = true;

    Hexagon(int x, int y, int w, int hue)
    {
        originX = x;
        originY = y;
        currentX = x;
        currentY = y;
        mWidth = w;
        mHue = hue;
        mOrgHue = hue;
    }

    void updateHex()
    {
        //Applying the velocity
        this.currentX += this.velocity.x;
        this.currentY += this.velocity.y;
        
        //cutting velocity over time (Decay)
        if (mDecayVelocity)
        {
            velocity.mult(speedDecay);
        }

        //moving the hexagon back to original position, if not already there

        //getting distance between current position and original position
        //getting vector between the origin and the current position
        PVector originVec = new PVector(originX, originY);
        PVector currentVec = new PVector(currentX, currentY);
        PVector toOrigin = PVector.sub(originVec, currentVec);

        float distanceSq = abs(toOrigin.magSq());

        // --- Moving Hex back to origin ---
        if (mReturnsToOrigin)
        {
            //if the distance is less than the closeDistance, then snap to origin (if bool is true)
            if (distanceSq < sq(this.closeDistance) && mSnapToOrigin)
            {
                this.currentX = this.originX;
                this.currentY = this.originY;

                //resetting velocity
                this.velocity = new PVector(0, 0);

                //change to hexagons
                mVertices = 6;

                //move bool
                mIsMoving = false;
            }
            else //We'll add velocity towards the origin
            {
                //change to diamonds
                mVertices = 3;

                //normalizing the vector
                toOrigin = toOrigin.normalize();

                //adding this vector times speed to velocity
                //toOrigin.mult(this.returnSpeed * delta);
                //this.velocity.add(toOrigin);

                float targetX = originX;
                float dx = targetX - currentX;

                float targetY = originY;
                float dy = targetY - currentY;

                this.velocity.add(new PVector(dx * returnSpeed, dy * returnSpeed));

                //update the hue while moving
                mHue += 1;
                while (mHue > 360)
                {
                    mHue -= 360;
                }

                //changing bool
                mIsMoving = true;
            }
        }

        //changing shape based on distance
        if (distanceSq < sq(this.closeDistance + 5))
        {
            mVertices = 6;
        } else if (distanceSq < sq(30))
        {
            mVertices = 5;
        } else if (distanceSq < sq(60))
        {
            mVertices = 4;
        } else
        {
            mVertices = 3;
        }

        //if hex is at orgin, start return timer for color, but only if color is different
        if (mHue != mOrgHue)
        {
            if (originX == currentX && originY == currentY)
            {
                //increment timer
                mTimePassed += delta;

                //if time has reached full time, then move color back to original
                if (mTimePassed >= mTimeReturn)
                {
                    //determining is add or sub is quicker
                    int sub = 0;
                    int add = 0;

                    if (mHue > mOrgHue)
                    {
                        sub = abs(mHue - mOrgHue);
                        add = abs(360 - mHue + mOrgHue);
                    } else // mOrgHue > mHue
                    {
                        sub = abs(mHue + 360 - mOrgHue);
                        add = abs(mOrgHue - mHue);
                    }

                    //whichever is smaller is the one we use
                    if (sub < add)
                    {
                        mHue--;

                        while (mHue < 0)
                        {
                            mHue += 360;
                        }
                    } else //add
                    {
                        mHue++;

                        while (mHue > 360)
                        {
                            mHue -= 360;
                        }
                    }
                }
            }
        } else //reset timer
        {
            mTimePassed = 0.0;
        }

        //console.log("Velocity: " + this.velocity);
    }

    void drawHex() {
        //drawing a Hexagon at the desired location, with x and y being the center

        //no stroke for now
        strokeWeight(0);
        noStroke();

        //fill color
        fill(color(this.mHue, 360, 360, 300));

        //drawing the hexagon
        pushMatrix();

        //position
        translate((int)this.currentX, (int)this.currentY);

        //rotation
        rotateZ(velocity.heading());

        //if the hexagon has velocity, increase z value to make it appear in front
        if (this.velocity.magSq() != 0)
        {
            //TODO: make moving hexagons move in front of static ones
        }

        polygon(0, 0, this.mWidth, mVertices);
        popMatrix();
    }
};
