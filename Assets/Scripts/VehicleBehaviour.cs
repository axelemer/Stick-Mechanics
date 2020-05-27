using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class VehicleBehaviour : MonoBehaviour
{
    public float speed;
    public float rotationSpeed;
    public Rigidbody rb;

    void Start()
    {
        
    }

    void Update()
    {
        this.rb.AddForce(transform.forward * Input.GetAxis("Vertical") * speed * Time.deltaTime, ForceMode.VelocityChange);
        this.rb.AddTorque(transform.up * Input.GetAxis("Horizontal") * rotationSpeed * Time.deltaTime, ForceMode.VelocityChange);
    }
}
