var buffer = argument[0];
var msgId = buffer_read(buffer, buffer_u8);//find the tag

switch(msgId)
{
    case 1://latency response
        var time = buffer_read(buffer, buffer_u32);//read in the time from the server
        latency = current_time - time;//update our latency
    break;
    
    case 2://registration response
        var response = buffer_read(buffer, buffer_u8);
        
        switch(response)
        {
            case 0://failure
                scr_showNotification("Registration failed! Username already exists!");
            break;
            
            case 1://success
                room_goto(rm_mainMenu);
            break;
        }
    break;
    
    case 3://login response
        var response = buffer_read(buffer, buffer_u8);
        
        switch(response)
        {
            case 0://failure
                scr_showNotification("Login failed! Username doesn't exist or password is incorrect!");
            break;
            
            case 1://success
                room_goto(rm_mainMenu);
            break;
        }
    break;
    
    case 4://player ID response
        global.playerId = buffer_read(buffer, buffer_u32);
        scr_showNotification("Our playerId has been received!");
    break;
    
    case 5://remote player disconnect response
        var pId = buffer_read(buffer, buffer_u32);
        with (obj_remoteplayer)
        {
            if (remotePlayerId == pId)
            {
                instance_destroy();
            }
        }
    break;
    
    case 6://room change response
        var pId = buffer_read(buffer, buffer_u32);
        var pName = buffer_read(buffer, buffer_string);
        
        var instance = noone;

        with (obj_remoteplayer)
        {
            if (remotePlayerId == pId)
            {
                instance = id;
            }
        }
        
        if (instance == noone)//if this player doesn't yet exist
        {
            //only if we exist in the gameworld
            if (instance_exists(obj_localplayer))
            {
                //create a remote player
                var remotePlayer = instance_create(room_width/2, room_height/2, obj_remoteplayer);
                remotePlayer.remotePlayerId = pId;
                remotePlayer.remotePlayerName = pName;
            }
        }
        else//otherwise destroy this player as he/she is leaving
        {
            with (instance)
            {
                instance_destroy();
            }
        }
    break;
    
    case 7://player movement update response
        var pId = buffer_read(buffer, buffer_u32);
        var xx = buffer_read(buffer, buffer_f32);
        var yy = buffer_read(buffer, buffer_f32);
        var spriteNumber = buffer_read(buffer, buffer_u8);
        var headNumber = buffer_read(buffer, buffer_u8);
        var imageIndex = buffer_read(buffer, buffer_u8);
        var d = buffer_read(buffer, buffer_u8);
        
        with (obj_remoteplayer)
        {
            if (remotePlayerId == pId)
            {
                x = xx;
                y = yy;
                
                //decode the sprite number
                switch (spriteNumber)
                {
                    case 1:
                     //   image_index = 0;
                    break;
                    
                    case 2:
                    //    image_index = 1;
                    break;
                    
                    case 3:
                    //    image_index = 2;
                    break;
                    
                    case 4:
                    //    image_index = 3;
                    break;
                    
                    //case 5:
                     //   image_index = 0;
                    //break;
                }
                
                switch (headNumber)
                {
                    case 1:
                        obj_head.image_index = 0;
                    break;
                    
                    case 2:
                        obj_head.image_index = 1;
                    break;
                    
                    case 3:
                        obj_head.image_index = 2;
                    break;
                    
                    case 4:
                        obj_head.image_index = 3;
                    break;
                    
                }
                image_index = imageIndex;
                
                //decode our direction
                switch (d)
                {
                    case 1:
                        image_xscale = -1;
                    break;
                    
                    case 2:
                        image_xscale = 1;
                    break;
                }
            }
        }
    break;
    
    case 8:
        var pId = buffer_read(buffer, buffer_u32);
        var text = buffer_read(buffer, buffer_string);
        
        //find the owner of the message
        with (obj_remoteplayer)
        {
            if (remotePlayerId == pId)
            {
                //create the chat object to follow this remote player
                var chat = instance_create(x, y, obj_chat);
                chat.text = text;
                chat.owner = id;
            }
        }
    break;
}
