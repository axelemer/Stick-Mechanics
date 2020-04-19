using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class VehicleMovement : MonoBehaviour
{
    public SphereCollider sphere;
    public Rigidbody SphereRb;
    public List<ParticleSystem> driftParticles;

    public float angleToDrift;
    public float rotationSpeed;
    public float changeRotationSpeed;
    public float speed;
    public float raycastLenght;
    public Transform rayP1;
    private Vector3 dir;

    void Start()
    {

    }

    void Update()
    {
        RaycastHit hit;
        Quaternion surfaceRotation = new Quaternion();
        LayerMask floorMask = LayerMask.GetMask("Floor");

        if (Physics.Raycast(rayP1.position, rayP1.position - rayP1.up * raycastLenght, out hit, 4f, floorMask))
        {
            if (hit.collider)
            {
                surfaceRotation = Quaternion.FromToRotation(transform.up, hit.normal) * transform.rotation;
            }
        }
        transform.rotation = Quaternion.Lerp(transform.rotation,
                                Quaternion.Euler(surfaceRotation.eulerAngles.x, transform.rotation.eulerAngles.y, surfaceRotation.eulerAngles.z),
                                    changeRotationSpeed * Time.deltaTime);

        Drift();

        //transform.rotation = Quaternion.Euler(surfaceRotation.eulerAngles.x, transform.rotation.eulerAngles.y, surfaceRotation.eulerAngles.z);

        dir = new Vector3(0, transform.rotation.eulerAngles.y, 0);
        transform.Rotate(transform.up, Input.GetAxis("Horizontal") * rotationSpeed * Time.deltaTime);
    }

    private void Drift()
    {
        if (Vector3.Angle(transform.position - SphereRb.position, transform.forward) < angleToDrift)
        {
            foreach (var p in driftParticles)
            {
                if (!p.isPlaying)
                    p.Play();
            }
        }
        else
        {
            foreach (var p in driftParticles)
            {
                if (p.isPlaying)
                    p.Stop();
            }
        }
    }

    private void FixedUpdate()
    {
        //Torque gira en Vector Right, dirección hacia Forward
        SphereRb.AddTorque(this.transform.right * speed * Input.GetAxis("Vertical") * Time.fixedDeltaTime, ForceMode.Impulse);
    }

    private void OnDrawGizmos()
    {
        Gizmos.color = Color.yellow;
        Gizmos.DrawLine(transform.position, transform.position + dir * 5);
        Gizmos.color = Color.blue;
        Gizmos.DrawLine(transform.position, SphereRb.velocity * 5);
        Gizmos.color = Color.red;
        Gizmos.DrawLine(rayP1.position, rayP1.position - rayP1.up * raycastLenght);
    }
}
