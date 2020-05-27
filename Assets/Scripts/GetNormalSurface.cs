using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GetNormalSurface : MonoBehaviour
{
    internal Vector3 normalSurface = new Vector3();
    private void OnCollisionStay(Collision collision)
    {
        if(collision.gameObject.layer == 9) // Layer 9 -> floor
        {
            normalSurface = collision.contacts[0].normal;
        }
    }
}
