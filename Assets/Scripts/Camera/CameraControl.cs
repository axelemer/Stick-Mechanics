using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraControl : MonoBehaviour
{
    public Transform target;
    public Transform point;
    public Vector3 offset;
    public int distanceToPlayer;
    public float timeToFollow;

    private void Update()
    {
        timeToFollow -= Time.deltaTime;
        if (target != null && timeToFollow <= 0)
        {
            Vector3 expectedPosition = target.position + offset;

            if (expectedPosition.magnitude < distanceToPlayer)
            transform.position = Vector3.Lerp(transform.position, expectedPosition, 0.02f);
            else if (expectedPosition.y > distanceToPlayer)
                transform.position = Vector3.Lerp(transform.position, expectedPosition, 0.05f);
            else
                transform.position = Vector3.Lerp(transform.position, expectedPosition, 0.05f);
        }
    }
}
