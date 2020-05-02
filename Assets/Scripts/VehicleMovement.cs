using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class VehicleMovement : MonoBehaviour
{
    public SphereCollider sphere;
    public Rigidbody SphereRb;
    public Transform head;
    public Transform canyon;
    public float canyonOffset;
    public Transform aimDir;
    public List<ParticleSystem> driftParticles;

    public float angleToDrift;
    public float headRotation;
    public float rotationSpeed;
    public float changeRotationSpeed;
    public float speed;
    public float raycastLenght;
    public Transform rayP1;

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
        
        transform.Rotate(transform.up, Input.GetAxis("Horizontal") * rotationSpeed * Time.deltaTime);

        RotateHead();
    }

    private void RotateHead()
    {
        //Head
        Quaternion headAim = Quaternion.FromToRotation(head.forward, aimDir.forward) * head.localRotation;
        head.localRotation = Quaternion.Slerp(head.localRotation, Quaternion.Euler(0, headAim.eulerAngles.y, 0), headRotation * Time.deltaTime);

        //Canyon
        canyon.localRotation = Quaternion.Slerp(canyon.localRotation, Quaternion.Euler(aimDir.rotation.eulerAngles.x - canyonOffset, 0, 0), headRotation * Time.deltaTime);
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
        Gizmos.color = Color.blue;
        Gizmos.DrawLine(transform.position, SphereRb.velocity * 5);
        Gizmos.color = Color.red;
        Gizmos.DrawLine(rayP1.position, rayP1.position - rayP1.up * raycastLenght);
    }
}
