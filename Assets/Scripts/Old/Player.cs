using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Player : MonoBehaviour
{
    private StateMachine<OnCondition> fsm;
    public string stateName;

    public Animator anim;

    public float speed;
    public float rotationSpeed;
    private Vector2 dir;

    void Start()
    {
        var idle = new State<OnCondition>("Idle");
        var move = new State<OnCondition>("Move");

        idle.OnUpdate += () =>
        {
            Move(Direction());
            if(Direction().magnitude != 0)
            {
                fsm.Feed(OnCondition.move);
            }
        };

        move.OnUpdate += () =>
        {
            Move(Direction());
            if (Direction().magnitude == 0)
            {
                fsm.Feed(OnCondition.idle);
            }
        };

        idle.AddTransition(OnCondition.move, move);
        move.AddTransition(OnCondition.idle, idle);

        fsm = new StateMachine<OnCondition>(idle);
    }

    void Update()
    {
        fsm.Update();
        stateName = fsm.currentState.name;
    }

    private Vector2 Direction()
    {
        dir = new Vector2(Input.GetAxis("Horizontal"), Input.GetAxis("Vertical"));
        return dir;
    }

    private void Move(Vector2 dir)
    {
        transform.position += transform.forward * speed * Direction().magnitude * Time.deltaTime;
        transform.forward = Vector3.Slerp(transform.forward, new Vector3(transform.forward.x + Direction().x,
                                                                            transform.forward.y,
                                                                                transform.forward.z + Direction().y), rotationSpeed);
        anim.SetFloat("MoveFloat", dir.magnitude);
    }
}

public enum OnCondition
{
    idle,
    move
}
