using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraPointBehaviour : MonoBehaviour
{
    public Rigidbody rb;
    public float lerpValue;

    void Update()
    {
        //transform.position = Vector3.Lerp(transform.position, transform.forward * rb.velocity.magnitude, lerpValue);
    }
}
