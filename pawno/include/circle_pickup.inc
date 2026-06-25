#define PICKUP_RED     (0xFFCC0000)
#define PICKUP_GREEN     (0xFF00FF00)
#define PICKUP_BLUE   (0xFF3300FF)

stock CreateCirclePickup(color, Float:x, Float:y, Float:z, worldid = -1, interiorid = -1, playerid = -1)
{
    new objectid;
    objectid = CreateDynamicObject(1316, Float:x, Float:y, Float:z - 0.8, 0.0, 0.0, 0.0, worldid, interiorid, playerid, 40.0, 40.0);
    SetDynamicObjectMaterial(objectid, 0, -1, "none", "none", color);

    return objectid;
}

stock Create3DText(message[], Float:x, Float:y, Float:z, worldid = -1, interiorid = -1, playerid = -1)
{

    new objectid;
    objectid = CreateDynamicObject(2659, x, y, z, 0.000000, 0.000000, 0.000000, worldid, interiorid, playerid, 300.00, 300.00); 
    SetDynamicObjectMaterialText(objectid, 0, sprintf("{FFFF00}%s", message), 120, "Fixedsys", 42, 1, 0x00000000, 0x00000000, 1);
    return objectid;
}

stock CreateColorPickup(color, Float:x, Float:y, Float:z, worldid = -1, interiorid = -1, playerid = -1)
{
    new modelid;
    modelid = CreateDynamicPickup(modelid, Float:x, Float:y, Float:z - 0.8, 0.0, 0.0, 0.0, worldid, interiorid, playerid, 40.0, 40.0);
    SetDynamicObjectMaterial(modelid, 0, -1, "none", "none", color);

    return modelid;
}
