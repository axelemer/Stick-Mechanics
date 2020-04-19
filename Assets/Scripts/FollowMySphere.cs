using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FollowMySphere : MonoBehaviour
{
    public Transform mySphere;
    public float lerpValue;
    
    void Update()
    {
        transform.position = Vector3.Lerp(transform.position, mySphere.position, lerpValue * Time.deltaTime);
    }
}
