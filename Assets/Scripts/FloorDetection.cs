using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FloorDetection : MonoBehaviour
{
    public Quaternion floorRotation = new Quaternion();

    private void OnTriggerEnter(Collider other)
    {
        if(other.gameObject.layer == 9)
        {
            GetFloorRotation(other);
        }
    }

    public void GetFloorRotation(Collider floor)
    {
        //floorRotation = floor.
    }
}
