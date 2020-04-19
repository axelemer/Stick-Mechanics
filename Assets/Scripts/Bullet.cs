using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bullet : MonoBehaviour
{
    public float velocity;
    public GameObject boomParticle;

    void Update()
    {
        transform.position += transform.forward * velocity * Time.deltaTime;
    }

    private void OnTriggerEnter(Collider other)
    {
        Explote();
    }

    private void OnCollisionEnter(Collision collision)
    {
        Explote();
    }

    private void Explote()
    {
        Shake.instance.ShakeCamera(0.1f, 0.1f);
        Instantiate(boomParticle, transform.position + Vector3.up/2, Quaternion.identity);
        Destroy(this.gameObject);
    }
}
