using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerBehaviour : MonoBehaviour
{
    public GameObject bullet;
    public Transform shootPoint;

    void Start()
    {
        
    }
    
    void Update()
    {
        if(Input.GetKeyDown(KeyCode.Mouse0))
        {
            Attack();
        }
    }

    private void Attack()
    {
        Instantiate(bullet, shootPoint.position, shootPoint.rotation);
        Shake.instance.ShakeCamera(0.05f, 0.05f);
    }
}
